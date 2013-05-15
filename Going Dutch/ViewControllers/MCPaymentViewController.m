//
//  MCPaymentViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 29-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPaymentViewController.h"
#import "MCPayment.h"
#import "MCPerson.h"    
#import "MCSharedBill.h"
#import "MCPeople.h"

@interface MCPaymentViewController ()

@end

@implementation MCPaymentViewController

@synthesize thisPayment;
@synthesize tonightsBill;
@synthesize didSomethingChange;
@synthesize withANewPayment;
@synthesize delegate;

#pragma mark - actions

- (void)backButtonPressed:(id)selector
{
    NSLog(@"MCPaymentViewController: Done button pressed.");
    if (didSomethingChange) {
        if (thisPayment != nil) {
            [thisPayment setPlace:[placeView text]];
            [thisPayment setMoney:[paidViewNumber doubleValue]];
            [thisPayment setPayingPerson:payerViewPerson];
        }
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void)removePayment:(id)selector
{
    [[self delegate] removePayment:thisPayment fromPaymentViewController:self];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)cancelPersonPicker:(id)selector
{
    // Set the text of the textView back and resign first responder
    [payerView setText:[[thisPayment payingPerson] firstName]];
    [payerView resignFirstResponder];
}

- (void)donePersonPicker:(id)selector
{
    NSInteger row = [personPickerView selectedRowInComponent:0];
    payerViewPerson = [[[tonightsBill people] allPeople] objectAtIndex:row];
    [payerView setText:[payerViewPerson getFullName]];
    [payerView resignFirstResponder];
    didSomethingChange = YES;
    [[self navigationItem] setRightBarButtonItem:doneButton animated:YES];
}

- (void)cancelNumberPad:(id)selector
{
    // Restore Paidview and resignFirstResponder.
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [paidView setText:[nf stringFromNumber:[[NSNumber alloc] initWithDouble:[thisPayment money]]]];
    [paidView resignFirstResponder];
}

- (void)doneNumberPad:(id)selector
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    [nf setLocale:[NSLocale currentLocale]];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    paidViewNumber = [nf numberFromString:[paidView text]];
    
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [paidView setText:[nf stringFromNumber:paidViewNumber]];
    didSomethingChange = YES;
    [paidView resignFirstResponder];
    [[self navigationItem] setRightBarButtonItem:doneButton animated:YES];
}

- (void)cancelChangesForEntirePayment:(id)selector
{
    if (withANewPayment) {
        [[self delegate] removePayment:thisPayment fromPaymentViewController:self];
    }
    [[self navigationController] popViewControllerAnimated:YES];
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
            withANewPayment = NO;
        } else {
            thisPayment = [[MCPayment alloc] init];
            [tonightsBill addPayment:thisPayment];
            [thisPayment setPayingPerson:[[[tonightsBill people] allPeople] objectAtIndex:0]];
            withANewPayment = YES;
        }
    }
    return self;
}

#pragma mark - PickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[[[tonightsBill people] allPeople] objectAtIndex:row] getFullName];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    payerViewPerson = [[[tonightsBill people] allPeople] objectAtIndex:row];
    [payerView setText:[payerViewPerson getFullName]];
    didSomethingChange = YES;
}

#pragma mark - PickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[[tonightsBill people] allPeople] count];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == placeView) {
        [textField resignFirstResponder];
        didSomethingChange = YES;
        [[self navigationItem] setRightBarButtonItem:doneButton animated:YES];
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
        if (didSomethingChange) {
            [paidView setText:[nf stringFromNumber:paidViewNumber]];
        } else {
            [paidView setText:[nf stringFromNumber:[[NSNumber alloc] initWithDouble:[thisPayment money]]]];
        }
    }
    if (textField == payerView) {
        NSInteger row = 0;
        if ([thisPayment payingPerson]) {
            row = [[[tonightsBill people] allPeople] indexOfObject:[thisPayment payingPerson]];
        } else {
            row = [personPickerView selectedRowInComponent:0];
        }
        MCPerson *theSelectedPerson = [[[tonightsBill people] allPeople] objectAtIndex:row];
        [payerView setText:[theSelectedPerson getFullName]];
        [personPickerView selectRow:row inComponent:0 animated:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == paidView) {
        NSLog(@"Stuk?");
    }
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
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                               target:self
                                                               action:@selector(backButtonPressed:)];
    if (didSomethingChange) {
        [[self navigationItem] setRightBarButtonItem:doneButton];
    }
    cancelChangesForEntirePaymentButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelChangesForEntirePayment:)];
    [[self navigationItem] setLeftBarButtonItem:cancelChangesForEntirePaymentButton];
    
    // Fill in the form if data is present.
    [payerView setText:[[thisPayment payingPerson] getFullName]];
    [payerView setDelegate:self];
    [placeView setText:[thisPayment place]];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setLocale:[NSLocale currentLocale]];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setFormatterBehavior:NSNumberFormatterCurrencyStyle];
    paidViewNumber = [[NSNumber alloc] initWithDouble:[thisPayment money]];
    if (!withANewPayment) {
        [paidView setText:[nf stringFromNumber:paidViewNumber]];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateAndTimeLabel setText:[dateFormatter stringFromDate:[thisPayment timePaid]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // If tonight's bill was passed along.
    if (!withANewPayment) {
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
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                               target:self
                                                               action:@selector(doneNumberPad:)];
    [inputAccossoryNumberPad setItems:[[NSArray alloc] initWithObjects:cancelButton, flexButton, doneButton, nil] animated:YES];
    [paidView setInputAccessoryView:inputAccossoryNumberPad];
    [paidView setDelegate:self];

    [placeView setDelegate:self];
    payerViewPerson = [thisPayment payingPerson];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
