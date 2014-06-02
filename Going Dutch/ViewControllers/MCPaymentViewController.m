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
#import "MCTwoLabelsTitleView.h"

#import "MCPaymentPresenceTableViewCell_iPhone.h"

@interface MCPaymentViewController ()

@end

@implementation MCPaymentViewController

//@synthesize thisPayment;
@synthesize tonightsBill;
//@synthesize didSomethingChange;
@synthesize isNew;
@synthesize delegate;

#pragma mark - action

- (IBAction)tabElseWhereAndDismissKeyboard:(id)sender {
    if ([itemView isFirstResponder]) {
        [itemView endEditing:YES];
        [itemView setText:[_thisPayment descriptionOfPayment]];
    }
    if ([payerView isFirstResponder]) {
        [self cancelPersonPicker:self];
    }
    if ([paidView isFirstResponder]) {
        [self cancelNumberPad:self];
    }
}

- (IBAction)mainCancelButtonPressed:(id)sender
{
//    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
//    [context performBlockAndWait:^{
//        [[context undoManager] endUndoGrouping];
//        [[context undoManager] disableUndoRegistration];
//        if ([[context undoManager] canUndo]) {
//            [[context undoManager] undoNestedGroup];
//        }
//    }];
    if ([[[_thisPayment managedObjectContext] undoManager] canUndo]) {
        [[MCWeAllPayStoreController defaultStore] endUndoGroupAndUndo];
    } else {
        [[MCWeAllPayStoreController defaultStore] endUndoGroup];
    }
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)mainDoneButtonPressed:(id)sender
{
    NSLog(@"MCPaymentViewController: Done button pressed.");
    if ([payerView isFirstResponder]) {
        [self donePersonPicker:self];
    }
    if ([paidView isFirstResponder]) {
        [self doneNumberPad:self];
    }
    if ([itemView isFirstResponder]) {
        [self storePlaceViewData];
    }

    if ([[[_thisPayment managedObjectContext] undoManager] canUndo]) {
        [[MCWeAllPayStoreController defaultStore] endUndoGroupAndProcess];
    } else {
        [[MCWeAllPayStoreController defaultStore] endUndoGroup];
    }
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelPersonPicker:(id)selector
{
    // Set the text of the textView back and resign first responder
    peoplePickerCancelled = YES;
    [payerView setText:[[_thisPayment payingPerson] getFullName]];
    if ([_thisPayment payingPerson]) {
        [self setCircularImageOnPictureView:[[_thisPayment payingPerson] picture]];
    } else {
        [_payerPicture setImage:nil];
    }
    [payerView resignFirstResponder];
}

- (void)donePersonPicker:(id)selector
{
    if ([[tonightsBill peoplePresent] count] > 0) {
        NSInteger row = [personPickerView selectedRowInComponent:0];
        [_thisPayment setPayingPerson:listOfPeople[row]];
//        [payerView setText:[[_thisPayment payingPerson] getFullName]];
//        didSomethingChange = YES;
        NSDate *nu = [NSDate date];
        [tonightsBill setDateModified:nu];
        [_thisPayment setDateModified:nu];
//        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    }
    [payerView resignFirstResponder];
}

- (void)cancelNumberPad:(id)selector
{
    // Restore Paidview and resignFirstResponder.
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [paidView setText:[nf stringFromNumber:[_thisPayment money]]];
    [paidView resignFirstResponder];
}

- (void)doneNumberPad:(id)selector
{
    [self storeMoneySpent];
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
    [tonightsBill setDateModified:nu];
    [_thisPayment setDateModified:nu];
//    didSomethingChange = YES;
}

#pragma mark - new in this class

- (id)initWithExistingPayment:(MCPayment *)thePayment fromBill:(MCSharedBill *)bill
{
    self = [super init];
    
    if (self) {
        tonightsBill = bill;
//        didSomethingChange = NO;
        if (thePayment) {
            _thisPayment = thePayment;
            isNew = NO;
        } else {
            _thisPayment = [MCPayment addPayment];
            [_thisPayment setOnWhichBill:bill];
            isNew = YES;
        }
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)setCircularImageOnPictureView:(UIImage *)image
{
    __weak MCPaymentViewController *weakSelf = self;
    
    dispatch_queue_t imageProcessQueue;
    imageProcessQueue = dispatch_queue_create("imageProcessQueue", NULL);
    
    dispatch_async(imageProcessQueue, ^{
        CGRect circularImageRect = CGRectMake(0, 0, 60, 60);
        UIImage *circularImage = [MCTools cutCircularImageFrom:image toDestinationRect:circularImageRect];
        dispatch_async(dispatch_get_main_queue(), ^{
            MCPaymentViewController *strongSelf = weakSelf;
            if (strongSelf) {
                [[strongSelf payerPicture] setImage:circularImage];
                [[strongSelf payerPicture] setNeedsDisplay];
            }
        });
    });
}

#pragma mark - PickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (listOfPeople == nil) {
        listOfPeople = [tonightsBill getArrayOfFullNamesOfPeoplePresent];
    }
    return [listOfPeople[row] getFullName];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [payerView setText:[listOfPeople[row] getFullName]];
    [_thisPayment setPayingPerson:listOfPeople[row]];
    [self setCircularImageOnPictureView:[listOfPeople[row] picture]];
}

#pragma mark - PickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[tonightsBill peoplePresent] count];
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
    /*if ([payerView isFirstResponder] || [paidView isFirstResponder] || [itemView isFirstResponder]) {
     [self setSwitchInputField:YES];
     return YES;
     } else {
     self.switchInputField = NO;
     return YES;
     }*/
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == paidView) {
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
    
    if (textField == payerView) {
        [[MCWeAllPayStoreController defaultStore] beginUndoGroupWithoutRegistration];
        peoplePickerCancelled = NO;
        NSInteger row = 0;
        MCPerson *payingPerson = [_thisPayment payingPerson];
        if (listOfPeople == nil) {
            listOfPeople = [tonightsBill getArrayOfFullNamesOfPeoplePresent];
        }
        if (payingPerson) {
            row = [listOfPeople indexOfObject:payingPerson];
        } else {
            row = [personPickerView selectedRowInComponent:0];
        }
        [payerView setText:[listOfPeople[row] getFullName]];
        [self setCircularImageOnPictureView:[listOfPeople[row] picture]];
        [personPickerView selectRow:row inComponent:0 animated:YES];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == paidView) {
        /*[self storeMoneySpent];*/
    } else if (textField == payerView) {
        if (!peoplePickerCancelled) {
            [[MCWeAllPayStoreController defaultStore] endUndoGroupAndProcessWithoutRegistration];
            [self donePersonPicker:self];
        } else {
            peoplePickerCancelled = YES;
            [[MCWeAllPayStoreController defaultStore] endUndoGroupAndUndoWithoutRegistration];
            [payerView setText:[[_thisPayment payingPerson] getFullName]];
            if ([_thisPayment payingPerson]) {
                [self setCircularImageOnPictureView:[[_thisPayment payingPerson] picture]];
            } else {
                NSLog(@"Is het stuk?");
                [self setCircularImageOnPictureView:nil];
            }
        }
    } else if (textField == itemView) {
        // Do something to store value of placeview.
        [self storePlaceViewData];
        NSDate *nu = [NSDate date];
        [tonightsBill setDateModified:nu];
        [_thisPayment setDateModified:nu];
    }
}

#pragma mark - Inherited from super

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [[context undoManager] enableUndoRegistration];
    [[context undoManager] beginUndoGrouping];
    
    // When _thisPayment was not passed along a new one should be created.
    if (!_thisPayment) {
        _thisPayment = [tonightsBill addPayment];
        isNew = YES;
//        didSomethingChange = YES;
    } else {
        isNew = NO;
    }
    
    _dataController = [[MCWeAllPayStoreController defaultStore] paymentPresenceDataControllerForDelegate:self];
    
    // If tonight's bill wasn't passed along.
    if (!tonightsBill) {
        NSLog(@"tonightsBill wasn't passed along.");
        @throw [NSException exceptionWithName:@"tonightsBill missing" reason:@"thisPayment didn't receive tonightsBill." userInfo:nil];
    }
    
    // Create an array sorted on people's firstName.
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"person.firstName" ascending:YES];
//    _paymentPresenceArray = [[_thisPayment peopleSharingPayment] sortedArrayUsingDescriptors:@[sortDescriptor]];
    
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
    [payerView setInputView:personPickerView];
    [payerView setInputAccessoryView:inputAccessoryPickerView];
    
    UIToolbar *inputAccossoryNumberPad = [[UIToolbar alloc] initWithFrame:toolbarRect];
    cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                 target:self
                                                                 action:@selector(cancelNumberPad:)];
    theDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                  target:self
                                                                  action:@selector(doneNumberPad:)];
    [inputAccossoryNumberPad setItems:@[cancelButton, flexButton, theDoneButton] animated:YES];
    [paidView setInputAccessoryView:inputAccossoryNumberPad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MCTools setAdBannerIfNotPaid:NO forViewController:self];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Navigationbar stuff
    if (!twoLabelTitleView) {
        twoLabelTitleView = [[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil][0];
        if (isNew) {
            [[twoLabelTitleView mainLabel] setText:NSLocalizedString(@"NEW_PAYMENT_HEADER", @"Header in the paymentView which state new Payment")];
            [[twoLabelTitleView subLabel] setText:NSLocalizedString(@"NEW_PAYMENT_SUBHEADER", @"Sub header in the paymentView which states Add payment data")];
        } else {
            [[twoLabelTitleView mainLabel] setText:NSLocalizedString(@"EXISTING_PAYMENT_HEADER", @"Header in the paymentView which states payment")];
            [[twoLabelTitleView subLabel] setText:NSLocalizedString(@"EXISTING_PAYMENT_SUBHEADER", @"Sub header in the paymentView which states edit payment data")];
        }
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            [[twoLabelTitleView mainLabel] setTextColor:[UIColor whiteColor]];
            [[twoLabelTitleView subLabel] setTextColor:[UIColor whiteColor]];
        }
        [[self navigationItem] setTitleView:twoLabelTitleView];
    }
    
    // Fill in the form if data is present.
    [payerView setText:[[_thisPayment payingPerson] getFullName]];
    [payerView setDelegate:self];
    [itemView setText:[_thisPayment descriptionOfPayment]];
    if ([_thisPayment payingPerson]) {
        [self setCircularImageOnPictureView:[[_thisPayment payingPerson] picture]];
    }

    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setLocale:[NSLocale currentLocale]];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setFormatterBehavior:NSNumberFormatterCurrencyStyle];
    if (!isNew) {
        [paidView setText:[nf stringFromNumber:[_thisPayment money]]];
    }
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
//    [dateAndTimeLabel setText:[dateFormatter stringFromDate:[_thisPayment dateModified]]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    if (isNew) {
        [tracker set:kGAIScreenName value:@"MCPaymentNewView_iPhone"];
    } else {
        [tracker set:kGAIScreenName value:@"MCPaymentDetailsView_iPhone"];
    }
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewDidDisappear:(BOOL)animated
{
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
    [[self tableView] beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
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
            break;
            
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            break;
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
    [cell setCircularImage:[[thisCellsPresence person] thumbnail]];
    [[cell isPresentSwitch] setOn:[[thisCellsPresence isPersonPresent] boolValue]];
    NSString *owesString = [NSString stringWithFormat:@"owes %@", [thisCellsPresence getCurrencyStringOfAverageOwe]];
    [[cell owesLabel] setText:owesString];
    [cell setThisCellsPaymentPresence:thisCellsPresence];
    
    // Set the cell alignment to headerView stuff
    NSLayoutConstraint *bazinga = [NSLayoutConstraint constraintWithItem:payerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[cell nameLabel] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-6.0];
    NSLayoutConstraint *payerPictureToUser = [NSLayoutConstraint constraintWithItem:_payerPicture attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:[cell personView] attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [[self tableView] addConstraints:@[bazinga, payerPictureToUser]];
    
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
