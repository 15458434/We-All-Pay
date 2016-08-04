//
//  MCPaymentViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 29-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPaymentViewController.h"

#import "MCPayment+addons.h"
#import "MCPerson+addons.h"
#import "MCSharedBill+addons.h"
#import "MCPaymentPresence+addons.h"
#import "MCWeAllPayStoreController.h"

#import "MCDismissMeBlockProtocol.h"

#import "We_all_pay-Swift.h"

typedef NS_ENUM(BOOL, ChildViewOpened) {
    isNotOpened,
    isOpened
};

@interface MCPaymentViewController ()

@property (weak, nonatomic) IBOutlet UITextField *payerNameField;
@property (weak, nonatomic) IBOutlet UITextField *itemView;
@property (weak, nonatomic) IBOutlet UITextField *paidView;

@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UIImageView *payerPicture;
@property (weak, nonatomic) IBOutlet UIImageView *categoryView;
@property (nonatomic) ChildViewOpened selectCurrencyTableViewController;

@property (strong, nonatomic) UIBarButtonItem *theDoneButton;
@property (strong, nonatomic) UIBarButtonItem *cancelChangesForEntirePaymentButton;
@property (strong, nonatomic) MCTwoLabelsTitleView *twoLabelTitleView;

@property (strong, nonatomic) MCPerson *payerViewPerson;
@property (strong, nonatomic) NSNumber *paidViewNumber;

@property (nonatomic, strong) NSArray *paymentPresenceArray;
@property (nonatomic, strong) NSFetchedResultsController *dataController;

@property (nonatomic, strong) UIPickerView *personPickerView;
@property (nonatomic, strong) NSArray<MCPerson *> *listOfPeople;
@property (nonatomic) BOOL peoplePickerCancelled;

@property (nonatomic) MCMoneyValueFieldDismissStatus kindOfPaidFieldDismiss;

@end

@implementation MCPaymentViewController

@synthesize delegate;

#pragma mark - action

- (IBAction)tabElseWhereAndDismissKeyboard:(id)sender {
    if ([_itemView isFirstResponder]) {
        [_itemView endEditing:YES];
        [_itemView setText:[_thisPayment descriptionOfPayment]];
    }
    if ([_payerNameField isFirstResponder]) {
        [self cancelPersonPicker:self];
    }
    if ([_paidView isFirstResponder]) {
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
    if ([_payerNameField isFirstResponder]) {
        [self donePersonPicker:self];
    }
    if ([_paidView isFirstResponder]) {
        [self doneNumberPad:self];
    }
    if ([_itemView isFirstResponder]) {
        [self storePlaceViewData];
    }

    if ([[[[MCWeAllPayStoreController defaultStore] mainThreadContext] undoManager] canUndo]) {
        [[MCWeAllPayStoreController defaultStore] endUndoGroupAndProcess];
    } else {
        [[MCWeAllPayStoreController defaultStore] endUndoGroup];
    }
    [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:^{
        [WhoPayingUserDefaultsStoreInterface sendToUserDefaultsStoreInterface:_tonightsBill];
    }];
}

- (IBAction)currencySelectionPressed:(id)sender
{
#ifdef DEBUG
    NSLog(@"%@, currencySelectionPressed", self);
#endif
    _kindOfPaidFieldDismiss = currencySelectionTapped;
    UIView *myFirstResponder = [[self view] getFirstResponder];
    [myFirstResponder resignFirstResponder];
    
    [self performSegueWithIdentifier:@"openSelectCurrency" sender:self];
}

- (void)cancelPersonPicker:(id)selector
{
    // Set the text of the textView back and resign first responder
    _peoplePickerCancelled = YES;
    [_payerNameField setText:[[_thisPayment payingPerson] getFullName]];
    if ([_thisPayment payingPerson]) {
        _payerPicture.image = _thisPayment.payingPerson.picture;
    } else {
        _payerPicture.image = nil;
    }
    [_payerNameField resignFirstResponder];
}

- (void)donePersonPicker:(id)selector
{
    if ([[_tonightsBill peoplePresent] count] > 0) {
        NSInteger row = [_personPickerView selectedRowInComponent:0];
        [_thisPayment setPayingPerson:_listOfPeople[row]];
//        [payerView setText:[[_thisPayment payingPerson] getFullName]];
//        didSomethingChange = YES;
        NSDate *nu = [NSDate date];
        [_tonightsBill setDateModified:nu];
        [_thisPayment setDateModified:nu];
//        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    }
    [_payerNameField resignFirstResponder];
}

- (void)cancelNumberPad:(id)selector
{
    // Restore Paidview and resignFirstResponder.
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [_paidView setText:[nf stringFromNumber:[_thisPayment money]]];
    _kindOfPaidFieldDismiss = cancelIsPressed;
    [_paidView resignFirstResponder];
}

- (void)doneNumberPad:(id)selector
{
    _kindOfPaidFieldDismiss = doneIsPressed;
    [_paidView resignFirstResponder];
}

- (void)storePlaceViewData
{
    [_itemView resignFirstResponder];
    [_thisPayment setDescriptionOfPayment:[_itemView text]];
//    didSomethingChange = YES;
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
}

- (void)storeMoneySpent
{
    CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_thisPayment.currency.code];
    [[MCWeAllPayStoreController defaultStore] beginUndoGroupWithoutRegistration];
    _thisPayment.money = [cf doubleFromString:_paidView.text];
    [_thisPayment recalculateAveragePeopleOweAndStore];
    [[MCWeAllPayStoreController defaultStore] endUndoGroupWithoutRegistration];
    _paidView.text = [cf stringForObjectValue:_thisPayment.money];
    
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    NSDate *nu = [NSDate date];
    [_tonightsBill setDateModified:nu];
    [_thisPayment setDateModified:nu];
//    didSomethingChange = YES;
    [[MCWeAllPayStoreController defaultStore] endUndoGroupWithoutRegistration];
}

#pragma mark - new in this class

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)tappedInTheBackground:(id)selector
{
    _kindOfPaidFieldDismiss = backgroundTapped;
    [self dismissKeyboard];
}

- (void)dismissKeyboard
{
    if ([_paidView isFirstResponder]) {
        [_paidView resignFirstResponder];
    } else if ([_itemView isFirstResponder]) {
        [_itemView resignFirstResponder];
    } else if ([_payerNameField isFirstResponder]) {
        [_payerNameField resignFirstResponder];
    }
}

#pragma mark - PickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (_listOfPeople == nil) {
        _listOfPeople = [_tonightsBill getArrayOfPeopleSortedOnFullNames];
    }
    return [_listOfPeople[row] getFullName];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [_payerNameField setText:[_listOfPeople[row] getFullName]];
    [_thisPayment setPayingPerson:_listOfPeople[row]];
    _payerPicture.image = [_listOfPeople[row] picture];
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
    if (textField == _itemView) {
        [self storePlaceViewData];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _payerNameField) {
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
    if (textField == _paidView) {
        [[MCWeAllPayStoreController defaultStore] beginUndoGroupWithoutRegistration];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
        [numberFormatter setLocale:[NSLocale currentLocale]];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *thisPaymentMoneyString = [numberFormatter stringFromNumber:[_thisPayment money]];
        if ([thisPaymentMoneyString isEqualToString:@"0"]) {
            thisPaymentMoneyString = nil;
        }
        [_paidView setText:thisPaymentMoneyString];
    }
    
    if (textField == _payerNameField) {
        [[MCWeAllPayStoreController defaultStore] beginUndoGroupWithoutRegistration];
        _peoplePickerCancelled = NO;
        NSInteger row = 0;
        MCPerson *payingPerson = [_thisPayment payingPerson];
        if (_listOfPeople == nil) {
            _listOfPeople = [_tonightsBill getArrayOfPeopleSortedOnFullNames];
        }
        if (payingPerson) {
            row = [_listOfPeople indexOfObject:payingPerson];
        } else {
            row = [_personPickerView selectedRowInComponent:0];
        }
        [_payerNameField setText:[_listOfPeople[row] getFullName]];
        _payerPicture.image = [_listOfPeople[row] picture];
        [_personPickerView selectRow:row inComponent:0 animated:YES];
        _kindOfPaidFieldDismiss = otherTextFieldSelected;
    }
    
    if (textField == _itemView) {
        _kindOfPaidFieldDismiss = otherTextFieldSelected;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _paidView) {
#ifdef DEBUG
        NSLog(@"kindOfPaidFieldDismiss = %lu", (unsigned long)_kindOfPaidFieldDismiss);
#endif
        [self storeMoneySpent];
    } else if (textField == _payerNameField) {
        if (!_peoplePickerCancelled) {
            [[MCWeAllPayStoreController defaultStore] endUndoGroupWithoutRegistration];
            [self donePersonPicker:self];
        } else {
            _peoplePickerCancelled = YES;
            [[MCWeAllPayStoreController defaultStore] endUndoGroupAndUndoWithoutRegistration];
            [_payerNameField setText:[[_thisPayment payingPerson] getFullName]];
            if ([_thisPayment payingPerson]) {
                _payerPicture.image = _thisPayment.payingPerson.picture;
            } else {
                _payerPicture.image = nil;
            }
        }
        _kindOfPaidFieldDismiss = backgroundTapped;
    } else if (textField == _itemView) {
        // Do something to store value of placeview.
        [self storePlaceViewData];
        NSDate *nu = [NSDate date];
        [_tonightsBill setDateModified:nu];
        [_thisPayment setDateModified:nu];
        _kindOfPaidFieldDismiss = backgroundTapped;
    }
}

#pragma mark - Inherited from super

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _selectCurrencyTableViewController = isNotOpened;
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
    _personPickerView = [[UIPickerView alloc] init];
    [_personPickerView setDelegate:self];
    [_personPickerView setDataSource:self];
    [_personPickerView setShowsSelectionIndicator:YES];
    [_payerNameField setInputView:_personPickerView];
    [_payerNameField setInputAccessoryView:inputAccessoryPickerView];
    
    // Make sure a tap in the background dismisses the keyboard as well.
    UITapGestureRecognizer *thatTickles = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedInTheBackground:)];
    [thatTickles setCancelsTouchesInView:YES];
    [[self tableView] addGestureRecognizer:thatTickles];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Navigationbar stuff
    if (!_twoLabelTitleView) {
        _twoLabelTitleView = [[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil][0];
        if (_isNew) {
            [[_twoLabelTitleView mainLabel] setText:NSLocalizedString(@"NEW_PAYMENT_HEADER", @"Header in the paymentView which state new Payment")];
            [[_twoLabelTitleView subLabel] setText:NSLocalizedString(@"NEW_PAYMENT_SUBHEADER", @"Sub header in the paymentView which states Add payment data")];
        } else {
            [[_twoLabelTitleView mainLabel] setText:NSLocalizedString(@"EXISTING_PAYMENT_HEADER", @"Header in the paymentView which states payment")];
            [[_twoLabelTitleView subLabel] setText:NSLocalizedString(@"EXISTING_PAYMENT_SUBHEADER", @"Sub header in the paymentView which states edit payment data")];
        }
        [[self navigationItem] setTitleView:_twoLabelTitleView];
    }
    
    if (!_dataController) {
        _dataController = [[MCWeAllPayStoreController defaultStore] paymentPresenceDataControllerForDelegate:self];
        CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_thisPayment.currency.code];
        _paidView.text = [cf stringForObjectValue:_thisPayment.money];
        [[self tableView] reloadData];
        _selectCurrencyTableViewController = isNotOpened;
    }
    [[self tableView] reloadData];
    
    // Fill in the form if data is present.
    [_payerNameField setText:[[_thisPayment payingPerson] getFullName]];
    [_payerNameField setDelegate:self];
    [_itemView setText:[_thisPayment descriptionOfPayment]];
    if ([_thisPayment payingPerson]) {
        _payerPicture.image = _thisPayment.payingPerson.picture;
    }
    // Get category picture.
    NSArray *pictureObjects = [[CategoryPictureStoreController sharedController] pictureObjects];
    CategoryPictureObject *categoryObject = pictureObjects[[[_thisPayment categoryId] shortValue]];
    if (categoryObject.categoryId > 0) {
        _categoryView.image = categoryObject.largePicture;
        [_categoryButton setTitle:categoryObject.categoryDescription forState:UIControlStateNormal];
    } else {
        NSString *buttonText = NSLocalizedString(@"SELECT_CATEGORY", @"Select Category");
        _categoryView.image = categoryObject.largePicture;
        [_categoryButton setTitle:buttonText forState:UIControlStateNormal];
    }
    if (!_isNew || _selectCurrencyTableViewController == isOpened) {
        CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_thisPayment.currency.code];
        _paidView.text = [cf stringForObjectValue:_thisPayment.money];
    }
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
                [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeMove:
                [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [[self tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_thisPayment.currency.code];
                _paidView.text = [cf stringForObjectValue:_thisPayment.money];
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
    CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:thisCellsPresence.payment.currency.code];
    NSNumber *averageOwe = @(-thisCellsPresence.averageOweFromPayment.doubleValue);
    cell.owesLabel.text = [cf stringForObjectValue:averageOwe];
    [cell setThisCellsPaymentPresence:thisCellsPresence];
    
    // Set the cell alignment to headerView stuff
    NSLayoutConstraint *payerViewToCellNameLabel = [NSLayoutConstraint constraintWithItem:_payerNameField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[cell nameLabel] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-6.0];
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
#ifdef DEBUG
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
