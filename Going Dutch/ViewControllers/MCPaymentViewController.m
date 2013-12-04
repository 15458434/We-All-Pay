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

- (IBAction)dismissKeyboard:(id)sender
{
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

- (void)backButtonPressed:(id)selector
{
    NSLog(@"backButtonPresses wordt uitgevoerd.");
    
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
    NSLog(@"MCPaymentViewController: Done button pressed.");
    if (didSomethingChange) {
        NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
        [context performBlockAndWait:^{
            [[context undoManager] disableUndoRegistration];
            [context processPendingChanges];
        }];
    }
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)removePayment:(id)selector
{
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlockAndWait:^{
        [MCPayment deletePayment:thisPayment];
        [[context undoManager] disableUndoRegistration];
    }];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)cancelPersonPicker:(id)selector
{
    // Set the text of the textView back and resign first responder
    [payerView setText:[[thisPayment payingPerson] getFullName]];
    [payerView resignFirstResponder];
}

- (void)donePersonPicker:(id)selector
{
    NSInteger row = [personPickerView selectedRowInComponent:0];
    [thisPayment setPayingPerson:[listOfPeople objectAtIndex:row]];
    [payerView setText:[[thisPayment payingPerson] getFullName]];
    [payerView resignFirstResponder];
    didSomethingChange = YES;
    NSDate *nu = [NSDate date];
    [tonightsBill setDateModified:nu];
    [thisPayment setDateModified:nu];
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    //[itemView becomeFirstResponder];
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

- (void)cancelChangesForEntirePayment:(id)selector
{
    NSLog(@"cancelchangesForEntirePayment.");
    if (isNew) {
        [MCPayment deletePayment:thisPayment];
    }
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlockAndWait:^{
        [[context undoManager] disableUndoRegistration];
        if (didSomethingChange) {
            [[context undoManager] undoNestedGroup];
        }
    }];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
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
    return [[listOfPeople objectAtIndex:row] getFullName];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [payerView setText:[[listOfPeople objectAtIndex:row] getFullName]];
    [thisPayment setPayingPerson:[listOfPeople objectAtIndex:row]];
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

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == paidView) {
        /*[self storeMoneySpent];*/
    } else if (textField == payerView) {
        [self donePersonPicker:self];
        
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Navigationbar stuff
    if (!twoLabelTitleView) {
        twoLabelTitleView = [[[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil] objectAtIndex:0];
        if (isNew) {
            [[twoLabelTitleView mainLabel] setText:@"New payment"];
            [[twoLabelTitleView subLabel] setText:@"Add payment data"];
        } else {
            [[twoLabelTitleView mainLabel] setText:@"Payment"];
            [[twoLabelTitleView subLabel] setText:@"Edit payment data"];
        }
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            [[twoLabelTitleView mainLabel] setTextColor:[UIColor whiteColor]];
            [[twoLabelTitleView subLabel] setTextColor:[UIColor whiteColor]];
        }
        [[self navigationItem] setTitleView:twoLabelTitleView];
    }
    theDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                               target:self
                                                               action:@selector(backButtonPressed:)];
    if (![[self navigationItem] rightBarButtonItem]) {
        [[self navigationItem] setRightBarButtonItem:theDoneButton];
    }
    [[[self navigationItem] rightBarButtonItem] setEnabled:didSomethingChange];
    cancelChangesForEntirePaymentButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelChangesForEntirePayment:)];
    [[self navigationItem] setLeftBarButtonItem:cancelChangesForEntirePaymentButton];
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setWillShowButtons:NO];
    
    // Prepare the switch input mechanism.
    [self setSwitchInputField:YES];
    listOfInputs = [NSArray arrayWithObjects:payerView, itemView, paidView, nil];
    
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlockAndWait:^{
        [[context undoManager] enableUndoRegistration];
    }];
    
    // If tonight's bill was passed along.
    if (!isNew) {
        [[self navigationController] setToolbarHidden:NO animated:YES];
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                      target:self
                                                                                      action:@selector(removePayment:)];
        [self setToolbarItems:[[NSArray alloc] initWithObjects:deleteButton, nil] animated:YES];
        [[self navigationController] setToolbarHidden:NO animated:YES];
    } else {
        [[self navigationController] setToolbarHidden:YES animated:YES];
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
    NSArray *buttonArray = [[NSArray alloc] initWithObjects:cancelButton, flexButton, doneButtonToolbar, nil];
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
    [inputAccossoryNumberPad setItems:[[NSArray alloc] initWithObjects:cancelButton, flexButton, theDoneButton, nil] animated:YES];
    [paidView setInputAccessoryView:inputAccossoryNumberPad];
    [paidView setDelegate:self];
    
    [itemView setDelegate:self];
    
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

@end
