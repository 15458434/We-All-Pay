//
//  MCPaymentViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 29-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPaymentViewController.h"
#import "UIView+MCAddons.h"

#import "MCPayment+addons.h"
#import "MCPerson+addons.h"
#import "MCSharedBill+addons.h"
#import "MCPaymentPresence+addons.h"
#import "MCWeAllPayStoreController.h"
#import "MCTwoLabelsTitleView.h"

#import "MCPaymentPresenceTableViewCell_iPhone.h"
#import "MCDismissMeBlockProtocol.h"

#import "MCCategoryPictureStoreController.h"
#import "MCCategoryPictureObject.h"

#import "MCWhoPayingUserDefaultsStoreInterface+WeAllPay.h"

typedef NS_ENUM(BOOL, ChildViewOpened) {
    isNotOpened,
    isOpened
};

@interface MCPaymentViewController ()

@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UIImageView *payerPicture;
@property (weak, nonatomic) IBOutlet UIImageView *categoryView;
@property (nonatomic) ChildViewOpened selectCurrencyTableViewController;

@end

@implementation MCPaymentViewController

@synthesize delegate;

#pragma mark - action

- (IBAction)tabElseWhereAndDismissKeyboard:(id)sender {
    if ([itemView isFirstResponder]) {
        [itemView endEditing:YES];
        [itemView setText:[_thisPayment descriptionOfPayment]];
    }
    if ([payerNameField isFirstResponder]) {
        [self cancelPersonPicker:self];
    }
    if ([paidView isFirstResponder]) {
        [self cancelNumberPad:self];
    }
}

- (IBAction)mainCancelButtonPressed:(id)sender
{
    [self dismissKeyboard];
    if ([[[[MCWeAllPayStoreController defaultStore] mainThreadContext] undoManager] canUndo]) {
        [[MCWeAllPayStoreController defaultStore] endUndoGroupAndUndo];
    } else {
        [[MCWeAllPayStoreController defaultStore] endUndoGroup];
    }
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)mainDoneButtonPressed:(id)sender
{
    NSLog(@"MCPaymentViewController: Done button pressed.");
    if ([payerNameField isFirstResponder]) {
        [self donePersonPicker:self];
    }
    if ([paidView isFirstResponder]) {
        [self doneNumberPad:self];
    }
    if ([itemView isFirstResponder]) {
        [self storePlaceViewData];
    }

    if ([[[[MCWeAllPayStoreController defaultStore] mainThreadContext] undoManager] canUndo]) {
        [[MCWeAllPayStoreController defaultStore] endUndoGroupAndProcess];
    } else {
        [[MCWeAllPayStoreController defaultStore] endUndoGroup];
    }
    [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:^{
        [MCWhoPayingUserDefaultsStoreInterface sendToUserDefaultsStoreInterface:_tonightsBill];
    }];
}

- (IBAction)currencySelectionPressed:(id)sender
{
#if DEBUG
    NSLog(@"%@, currencySelectionPressed", self);
#endif
    kindOfPaidFieldDismiss = currencySelectionTapped;
    UIView *myFirstResponder = [[self view] getFirstResponder];
    [myFirstResponder resignFirstResponder];
    
    [self performSegueWithIdentifier:@"openSelectCurrency" sender:self];
}

- (void)cancelPersonPicker:(id)selector
{
    // Set the text of the textView back and resign first responder
    peoplePickerCancelled = YES;
    [payerNameField setText:[[_thisPayment payingPerson] getFullName]];
    if ([_thisPayment payingPerson]) {
        _payerPicture.image = _thisPayment.payingPerson.picture;
    } else {
        _payerPicture.image = nil;
    }
    [payerNameField resignFirstResponder];
}

- (void)donePersonPicker:(id)selector
{
    if ([[_tonightsBill peoplePresent] count] > 0) {
        NSInteger row = [personPickerView selectedRowInComponent:0];
        [_thisPayment setPayingPerson:listOfPeople[row]];
//        [payerView setText:[[_thisPayment payingPerson] getFullName]];
//        didSomethingChange = YES;
        NSDate *nu = [NSDate date];
        [_tonightsBill setDateModified:nu];
        [_thisPayment setDateModified:nu];
//        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    }
    [payerNameField resignFirstResponder];
}

- (void)cancelNumberPad:(id)selector
{
    // Restore Paidview and resignFirstResponder.
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [paidView setText:[nf stringFromNumber:[_thisPayment money]]];
    kindOfPaidFieldDismiss = cancelIsPressed;
    [paidView resignFirstResponder];
}

- (void)doneNumberPad:(id)selector
{
//    [self storeMoneySpent];
    kindOfPaidFieldDismiss = doneIsPressed;
    [paidView resignFirstResponder];
}

- (void)storePlaceViewData
{
    [itemView resignFirstResponder];
    [_thisPayment setDescriptionOfPayment:[itemView text]];
//    didSomethingChange = YES;
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
}

- (void)storeMoneySpent
{
    [_thisPayment putMoneyValueAsAString:[paidView text]];

    [paidView setText:[_thisPayment getMoneyValueInCurrencyAsAString]];
    
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    NSDate *nu = [NSDate date];
    [_tonightsBill setDateModified:nu];
    [_thisPayment setDateModified:nu];
//    didSomethingChange = YES;
    [[MCWeAllPayStoreController defaultStore] endUndoGroupWithoutRegistration];
}

#pragma mark - new in this class

- (id)initWithExistingPayment:(MCPayment *)thePayment fromBill:(MCSharedBill *)bill
{
    self = [super init];
    
    if (self) {
        _tonightsBill = bill;
//        didSomethingChange = NO;
        if (thePayment) {
            _thisPayment = thePayment;
            _isNew = NO;
        } else {
            _thisPayment = [MCPayment addPayment];
            [_thisPayment setOnWhichBill:bill];
            _isNew = YES;
        }
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)tappedInTheBackground:(id)selector
{
    kindOfPaidFieldDismiss = backgroundTapped;
    [self dismissKeyboard];
}

- (void)dismissKeyboard
{
    if ([paidView isFirstResponder]) {
        [paidView resignFirstResponder];
    } else if ([itemView isFirstResponder]) {
        [itemView resignFirstResponder];
    } else if ([payerNameField isFirstResponder]) {
        [payerNameField resignFirstResponder];
    }
}

#pragma mark - PickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (listOfPeople == nil) {
        listOfPeople = [_tonightsBill getArrayOfFullNamesOfPeoplePresent];
    }
    return [listOfPeople[row] getFullName];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [payerNameField setText:[listOfPeople[row] getFullName]];
    [_thisPayment setPayingPerson:listOfPeople[row]];
    _payerPicture.image = [listOfPeople[row] picture];
}

#pragma mark - PickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[_tonightsBill peoplePresent] count];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == itemView) {
        [self storePlaceViewData];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == payerNameField) {
        // TODO: Better UI solution for the user.
        if ([[_tonightsBill peoplePresent] count] == 0) {
            NSLog(@"No people present on _tonightsBill, editing this textField is not allowed.");
            return NO;
        }
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == paidView) {
        [[MCWeAllPayStoreController defaultStore] beginUndoGroupWithoutRegistration];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
        [numberFormatter setLocale:[NSLocale currentLocale]];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *thisPaymentMoneyString = [numberFormatter stringFromNumber:[_thisPayment money]];
        if ([thisPaymentMoneyString isEqualToString:@"0"]) {
            thisPaymentMoneyString = nil;
        }
        [paidView setText:thisPaymentMoneyString];
    }
    
    if (textField == payerNameField) {
        [[MCWeAllPayStoreController defaultStore] beginUndoGroupWithoutRegistration];
        peoplePickerCancelled = NO;
        NSInteger row = 0;
        MCPerson *payingPerson = [_thisPayment payingPerson];
        if (listOfPeople == nil) {
            listOfPeople = [_tonightsBill getArrayOfFullNamesOfPeoplePresent];
        }
        if (payingPerson) {
            row = [listOfPeople indexOfObject:payingPerson];
        } else {
            row = [personPickerView selectedRowInComponent:0];
        }
        [payerNameField setText:[listOfPeople[row] getFullName]];
        _payerPicture.image = [listOfPeople[row] picture];
        [personPickerView selectRow:row inComponent:0 animated:YES];
        kindOfPaidFieldDismiss = otherTextFieldSelected;
    }
    
    if (textField == itemView) {
        kindOfPaidFieldDismiss = otherTextFieldSelected;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == paidView) {
#if DEBUG
        NSLog(@"kindOfPaidFieldDismiss = %d", kindOfPaidFieldDismiss);
#endif
        if (kindOfPaidFieldDismiss == cancelIsPressed) {
            // Restore stored value
            [paidView setText:[_thisPayment getMoneyValueInCurrencyAsAString]];
        } else if (kindOfPaidFieldDismiss == doneIsPressed) {
            [self storeMoneySpent];
        } else if (kindOfPaidFieldDismiss == otherTextFieldSelected) {
            [self storeMoneySpent];
        } else if (kindOfPaidFieldDismiss == currencySelectionTapped) {
            [self storeMoneySpent];
        } else if (kindOfPaidFieldDismiss == backgroundTapped){
            // Restore stored value
            [paidView setText:[_thisPayment getMoneyValueInCurrencyAsAString]];
        }
    } else if (textField == payerNameField) {
        if (!peoplePickerCancelled) {
            [[MCWeAllPayStoreController defaultStore] endUndoGroupWithoutRegistration];
            [self donePersonPicker:self];
        } else {
            peoplePickerCancelled = YES;
            [[MCWeAllPayStoreController defaultStore] endUndoGroupAndUndoWithoutRegistration];
            [payerNameField setText:[[_thisPayment payingPerson] getFullName]];
            if ([_thisPayment payingPerson]) {
                _payerPicture.image = _thisPayment.payingPerson.picture;
            } else {
                _payerPicture.image = nil;
            }
        }
        kindOfPaidFieldDismiss = backgroundTapped;
    } else if (textField == itemView) {
        // Do something to store value of placeview.
        [self storePlaceViewData];
        NSDate *nu = [NSDate date];
        [_tonightsBill setDateModified:nu];
        [_thisPayment setDateModified:nu];
        kindOfPaidFieldDismiss = backgroundTapped;
    }
}

#pragma mark - Inherited from super

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _selectCurrencyTableViewController = isNotOpened;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[MCWeAllPayStoreController defaultStore] beginUndoGroup];
    
    // When _thisPayment was not passed along a new one should be created.
    if (!_thisPayment) {
        _thisPayment = [_tonightsBill addPayment];
        _isNew = YES;
        if (_pathComponentsToOpen) {
            _thisPayment.payingPerson = _pathComponentsToOpen.lastObject;
        }
//        didSomethingChange = YES;
    } else {
        _isNew = NO;
    }
    
    // If tonight's bill wasn't passed along.
    if (!_tonightsBill) {
        NSLog(@"tonightsBill wasn't passed along.");
        @throw [NSException exceptionWithName:@"tonightsBill missing" reason:@"thisPayment didn't receive tonightsBill." userInfo:nil];
    }
    
    // Create Toolbar for the input accessory of payerView
    CGRect toolbarRect = CGRectMake(0, 0, [[self view] bounds].size.width, 44);
    UIToolbar *inputAccessoryPickerView = [[UIToolbar alloc] initWithFrame:toolbarRect];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(cancelPersonPicker:)];
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:nil
                                                                                action:nil];
    UIBarButtonItem *doneButtonToolbar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                       target:self
                                                                                       action:@selector(donePersonPicker:)];
    NSArray *buttonArray = @[cancelButton, flexButton, doneButtonToolbar];
    [inputAccessoryPickerView setItems:buttonArray animated:YES];
    personPickerView = [[UIPickerView alloc] init];
    [personPickerView setDelegate:self];
    [personPickerView setDataSource:self];
    [personPickerView setShowsSelectionIndicator:YES];
    [payerNameField setInputView:personPickerView];
    [payerNameField setInputAccessoryView:inputAccessoryPickerView];
    
    UIToolbar *inputAccossoryNumberPad = [[UIToolbar alloc] initWithFrame:toolbarRect];
    cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                 target:self
                                                                 action:@selector(cancelNumberPad:)];
    theDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                  target:self
                                                                  action:@selector(doneNumberPad:)];
    [inputAccossoryNumberPad setItems:@[cancelButton, flexButton, theDoneButton] animated:YES];
    [paidView setInputAccessoryView:inputAccossoryNumberPad];
    
    // Make sure a tap in the background dimisses the keyboard as well.
    UITapGestureRecognizer *thatTickles = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedInTheBackground:)];
    [thatTickles setCancelsTouchesInView:YES];
    [[self tableView] addGestureRecognizer:thatTickles];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MCTools setAdBannerIfNotPaid:NO forViewController:self];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Navigationbar stuff
    if (!twoLabelTitleView) {
        twoLabelTitleView = [[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil][0];
        if (_isNew) {
            [[twoLabelTitleView mainLabel] setText:NSLocalizedString(@"NEW_PAYMENT_HEADER", @"Header in the paymentView which state new Payment")];
            [[twoLabelTitleView subLabel] setText:NSLocalizedString(@"NEW_PAYMENT_SUBHEADER", @"Sub header in the paymentView which states Add payment data")];
        } else {
            [[twoLabelTitleView mainLabel] setText:NSLocalizedString(@"EXISTING_PAYMENT_HEADER", @"Header in the paymentView which states payment")];
            [[twoLabelTitleView subLabel] setText:NSLocalizedString(@"EXISTING_PAYMENT_SUBHEADER", @"Sub header in the paymentView which states edit payment data")];
        }
        [[self navigationItem] setTitleView:twoLabelTitleView];
    }
    
    if (!_dataController) {
        _dataController = [[MCWeAllPayStoreController defaultStore] paymentPresenceDataControllerForDelegate:self];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") && _selectCurrencyTableViewController == isOpened) {
            // Those lines won't update when coming from MCSelectCurrencyTableViewController on iOS 8 and later.
            // It's under an if statement, because only the iPhone 4 is effected.
            paidView.text = [_thisPayment getMoneyValueInCurrencyAsAString];
            [[self tableView] reloadData];
            _selectCurrencyTableViewController = isNotOpened;
        }
    }
    [[self tableView] reloadData];
    
    // Fill in the form if data is present.
    [payerNameField setText:[[_thisPayment payingPerson] getFullName]];
    [payerNameField setDelegate:self];
    [itemView setText:[_thisPayment descriptionOfPayment]];
    if ([_thisPayment payingPerson]) {
        _payerPicture.image = _thisPayment.payingPerson.picture;
    }
    // Get category picture.
    NSArray *pictureObjects = [[MCCategoryPictureStoreController sharedController] pictureObjects];
    MCCategoryPictureObject *categoryObject = pictureObjects[[[_thisPayment categoryId] shortValue]];
    if (categoryObject.categoryId > 0) {
        _categoryView.image = categoryObject.largePicture;
        [_categoryButton setTitle:categoryObject.categoryDescription forState:UIControlStateNormal];
    } else {
        NSString *buttonText = NSLocalizedString(@"SELECT_CATEGORY", @"Select Category");
        [_categoryButton setTitle:buttonText forState:UIControlStateNormal];
    }
    
    if (!_isNew || _selectCurrencyTableViewController == isOpened) {
        paidView.text = [_thisPayment getMoneyValueInCurrencyAsAString];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
#if DEBUG
    NSLog(@"%@ viewDidAppear", self);
#endif
    [super viewDidAppear:animated];

//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    if (isNew) {
//        [tracker set:kGAIScreenName value:@"MCPaymentNewView_iPhone"];
//    } else {
//        [tracker set:kGAIScreenName value:@"MCPaymentDetailsView_iPhone"];
//    }
//    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillDisappear:(BOOL)animated
{
#if DEBUG
    NSLog(@"%@, viewWillDisappear", self);
#endif
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
#if DEBUG
    NSLog(@"%@, viewDidDisappear", self);
#endif
    [super viewDidDisappear:animated];
    
    [MCTools setAdBannerIfNotPaid:NO forViewController:self];
    
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (self.isViewLoaded && self.view.window) {
        [[self tableView] beginUpdates];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.isViewLoaded && self.view.window) {
        [[self tableView] endUpdates];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (self.isViewLoaded && self.view.window) {
        switch(type) {
                
            case NSFetchedResultsChangeInsert:
                [[self tableView] insertRowsAtIndexPaths:@[newIndexPath]
                                        withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [[self tableView] deleteRowsAtIndexPaths:@[indexPath]
                                        withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [[self tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                paidView.text = [_thisPayment getMoneyValueInCurrencyAsAString];
                break;
                
            case NSFetchedResultsChangeMove:
                [[self tableView] deleteRowsAtIndexPaths:@[indexPath]
                                        withRowAnimation:UITableViewRowAnimationFade];
                [[self tableView] insertRowsAtIndexPaths:@[newIndexPath]
                                        withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[_dataController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPaymentPresenceTableViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:@"paymentPresenceCell_iPhone" forIndexPath:indexPath];
    
    // Set the cell contents
    MCPaymentPresence *thisCellsPresence = [_dataController objectAtIndexPath:indexPath];
    [[cell nameLabel] setText:[[thisCellsPresence person] getFullName]];
    cell.personView.image = thisCellsPresence.person.thumbnail;
    [[cell isPresentSwitch] setOn:[[thisCellsPresence isPersonPresent] boolValue]];
    NSString *owesPreString = NSLocalizedString(@"OWES_FROM_THIS_PAYMENT", @"owes");
    NSString *owesString = [NSString stringWithFormat:@"%@ %@", owesPreString, [thisCellsPresence getCurrencyStringOfAverageOwe]];
    [[cell owesLabel] setText:owesString];
    [cell setThisCellsPaymentPresence:thisCellsPresence];
    
    // Set the cell alignment to headerView stuff
    NSLayoutConstraint *payerViewToCellNameLabel = [NSLayoutConstraint constraintWithItem:payerNameField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[cell nameLabel] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-6.0];
    payerViewToCellNameLabel.identifier = [[thisCellsPresence.person getFullName] stringByAppendingString:@"payerViewToCellNameLabel"];
    NSLayoutConstraint *payerPictureToUser = [NSLayoutConstraint constraintWithItem:_payerPicture attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:[cell personView] attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    payerPictureToUser.identifier = [[thisCellsPresence.person getFullName] stringByAppendingString:@"payerPictureToUser"];
    [[self tableView] addConstraints:@[payerViewToCellNameLabel, payerPictureToUser]];
    
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if ([[segue identifier] isEqualToString:@"openSelectCurrency"]) {
#if DEBUG
         NSLog(@"%@, prepareForSegue openSelectCurrency", self);
#endif
         _selectCurrencyTableViewController = isOpened;
         id destination = [[segue destinationViewController] viewControllers][0];
         if ([destination conformsToProtocol:@protocol(MCThisPaymentProtocol)]) {
             [destination setThisPayment:_thisPayment];
         }
     }
     if ([[segue identifier] isEqualToString:@"selectCategory"]) {
         id destination = [[segue destinationViewController] viewControllers][0];
         if ([destination conformsToProtocol:@protocol(MCThisPaymentProtocol)]) {
             [destination setThisPayment:_thisPayment];
         }
     }
 }

@end
