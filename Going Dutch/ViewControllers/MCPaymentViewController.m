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
#import "MCWeAllPayStoreController.h"
#import "MCTwoLabelsTitleView.h"

@interface MCPaymentViewController ()

@end

@implementation MCPaymentViewController

@synthesize thisPayment;
@synthesize tonightsBill;
@synthesize didSomethingChange;
@synthesize isNew;
@synthesize delegate;

#pragma mark - action

- (IBAction)tabElseWhereAndDismissKeyboard:(id)sender {
    if ([itemView isFirstResponder]) {
        [itemView endEditing:YES];
        [itemView setText:[thisPayment descriptionOfPayment]];
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
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlockAndWait:^{
        [[context undoManager] endUndoGrouping];
        [[context undoManager] disableUndoRegistration];
        if (didSomethingChange) {
            [[context undoManager] undoNestedGroup];
        }
    }];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)mainDoneButtonPressed:(id)sender
{
    NSLog(@"MCPaymentViewController: Done button pressed.");
    self.switchInputField = NO;
    if ([payerView isFirstResponder]) {
        [self donePersonPicker:self];
    }
    if ([paidView isFirstResponder]) {
        [self doneNumberPad:self];
    }
    if ([itemView isFirstResponder]) {
        [self storePlaceViewData];
    }

    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [[context undoManager] endUndoGrouping];
    [[context undoManager] disableUndoRegistration];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:^{
        if (didSomethingChange) {
            NSManagedObjectContext *parentContext = [[[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext] parentContext];
            [parentContext performBlock:^{
                [parentContext processPendingChanges];
            }];
        }
    }];
}

- (void)cancelPersonPicker:(id)selector
{
    // Set the text of the textView back and resign first responder
    peoplePickerCancelled = YES;
    //[payerView setText:[[thisPayment payingPerson] getFullName]];
    [payerView resignFirstResponder];
}

- (void)donePersonPicker:(id)selector
{
    if ([[tonightsBill peoplePresent] count] > 0) {
        NSInteger row = [personPickerView selectedRowInComponent:0];
        [thisPayment setPayingPerson:listOfPeople[row]];
        [payerView setText:[[thisPayment payingPerson] getFullName]];
        didSomethingChange = YES;
        NSDate *nu = [NSDate date];
        [tonightsBill setDateModified:nu];
        [thisPayment setDateModified:nu];
        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    }
    [payerView resignFirstResponder];
}

- (void)cancelNumberPad:(id)selector
{
    // Restore Paidview and resignFirstResponder.
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [paidView setText:[nf stringFromNumber:[thisPayment money]]];
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
    [thisPayment setDescriptionOfPayment:[itemView text]];
    didSomethingChange = YES;
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
}

- (void)storeMoneySpent
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    [thisPayment setMoney:[nf numberFromString:[paidView text]]];
    
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [paidView setText:[nf stringFromNumber:[thisPayment money]]];
    
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    NSDate *nu = [NSDate date];
    [tonightsBill setDateModified:nu];
    [thisPayment setDateModified:nu];
    didSomethingChange = YES;
}

#pragma mark - new in this class

- (id)initWithExistingPayment:(MCPayment *)thePayment fromBill:(MCSharedBill *)bill
{
    self = [super init];
    
    if (self) {
        tonightsBill = bill;
        didSomethingChange = NO;
        if (thePayment) {
            thisPayment = thePayment;
            isNew = NO;
        } else {
            thisPayment = [MCPayment addPayment];
            [thisPayment setOnWhichBill:bill];
            isNew = YES;
        }
    }
    return self;
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
    [thisPayment setPayingPerson:listOfPeople[row]];
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
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
        [nf setLocale:[NSLocale currentLocale]];
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *ms = [nf stringFromNumber:[thisPayment money]];
        if ([ms isEqualToString:@"0"]) {
            ms = nil;
        }
        [paidView setText:ms];
    }
    
    if (textField == payerView) {
        NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
        [[context undoManager] beginUndoGrouping];
        peoplePickerCancelled = NO;
        NSInteger row = 0;
        MCPerson *payingPerson = [thisPayment payingPerson];
        if (listOfPeople == nil) {
            listOfPeople = [tonightsBill getArrayOfFullNamesOfPeoplePresent];
        }
        if (payingPerson) {
            row = [listOfPeople indexOfObject:payingPerson];
        } else {
            row = [personPickerView selectedRowInComponent:0];
        }
        [payerView setText:[[thisPayment payingPerson] getFullName]];
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
        NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
        [context performBlockAndWait:^{
            [[context undoManager] endUndoGrouping];
        }];
        if (!peoplePickerCancelled) {
            [self donePersonPicker:self];
        } else {
            peoplePickerCancelled = YES;
            [context performBlockAndWait:^{
                [[context undoManager] undoNestedGroup];
            }];
            [payerView setText:[[thisPayment payingPerson] getFullName]];
        }
    } else if (textField == itemView) {
        // Do something to store value of placeview.
        [self storePlaceViewData];
        NSDate *nu = [NSDate date];
        [tonightsBill setDateModified:nu];
        [thisPayment setDateModified:nu];
    }
    [self selectNextUITextField:textField];
}

#pragma mark - Inherited from super

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setWillShowButtons:NO];
    
    // Prepare the switch input mechanism.
    [self setSwitchInputField:YES];
    listOfInputs = @[payerView, itemView, paidView];
    
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [[context undoManager] enableUndoRegistration];
    [[context undoManager] beginUndoGrouping];
    
    // When thisPayment was not passed along a new one should be created.
    if (!thisPayment) {
        thisPayment = [tonightsBill addPayment];
        isNew = YES;
        didSomethingChange = YES;
    } else {
        isNew = NO;
    }
    
    // If tonight's bill wasn't passed along.
    if (!tonightsBill) {
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
    [payerView setText:[[thisPayment payingPerson] getFullName]];
    [payerView setDelegate:self];
    [itemView setText:[thisPayment descriptionOfPayment]];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setLocale:[NSLocale currentLocale]];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setFormatterBehavior:NSNumberFormatterCurrencyStyle];
    if (!isNew) {
        [paidView setText:[nf stringFromNumber:[thisPayment money]]];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateAndTimeLabel setText:[dateFormatter stringFromDate:[thisPayment dateModified]]];
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

@end
