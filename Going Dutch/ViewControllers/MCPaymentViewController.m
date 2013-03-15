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
@synthesize didSomethingChange;

#pragma mark - actions

- (void)removePayment:(id)selector
{
    [tonightsBill removePayment:thisPayment];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)cancelPersonPicker:(id)selector
{
    // Set the text of the textView back and resign first responder
    [payerView setText:[[thisPayment payingPerson] name]];
    [payerView resignFirstResponder];
}

- (void)donePersonPicker:(id)selector
{
    NSInteger row = [personPickerView selectedRowInComponent:0];
    payerViewPerson = [[[tonightsBill people] allPeople] objectAtIndex:row];
    [payerView setText:[payerViewPerson name]];
    [payerView resignFirstResponder];
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
    [paidView resignFirstResponder];
}

- (void)cancelChangesForEntirePayment:(id)selector
{
    if (withANewPayment) {
        [tonightsBill removePayment:thisPayment];
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
            withANewPayment = YES;
        }
    }
    return self;
}

#pragma mark - PickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[[[tonightsBill people] allPeople] objectAtIndex:row] name];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    payerViewPerson = [[[tonightsBill people] allPeople] objectAtIndex:row];
    [payerView setText:[payerViewPerson name]];
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
        [paidView setText:[nf stringFromNumber:paidViewNumber]];
    }
    if (textField == payerView) {
        NSInteger row = [personPickerView selectedRowInComponent:0];
        MCPerson *theSelectedPerson = [[[tonightsBill people] allPeople] objectAtIndex:row];
        [payerView setText:[theSelectedPerson name]];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == paidView) {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
        [nf setLocale:[NSLocale currentLocale]];
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];
        paidViewNumber = [nf numberFromString:[paidView text]];
        
        [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
        [paidView setText:[nf stringFromNumber:paidViewNumber]];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [payerView setText:[[thisPayment payingPerson] name]];
    [payerView setDelegate:self];
    [placeView setText:[thisPayment place]];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setLocale:[NSLocale currentLocale]];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setFormatterBehavior:NSNumberFormatterCurrencyStyle];
    paidViewNumber = [[NSNumber alloc] initWithDouble:[thisPayment money]];
    [paidView setText:[nf stringFromNumber:paidViewNumber]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateAndTimeLabel setText:[dateFormatter stringFromDate:[thisPayment timePaid]]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (thisPayment != nil) {
        [thisPayment setPlace:[placeView text]];
        [thisPayment setMoney:[paidViewNumber doubleValue]];
        [thisPayment setPayingPerson:payerViewPerson];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // If tonight's bill was passed along.
    if (tonightsBill) {
        [[self navigationController] setToolbarHidden:NO animated:YES];
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                      target:self
                                                                                      action:@selector(removePayment:)];
        [self setToolbarItems:[[NSArray alloc] initWithObjects:deleteButton, nil] animated:YES];
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
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(donePersonPicker:)];
    NSArray *buttonArray = [[NSArray alloc] initWithObjects:cancelButton, flexButton, doneButton, nil];
    [inputAccessoryPickerView setItems:buttonArray animated:YES];
    personPickerView = [[UIPickerView alloc] init];
    [personPickerView setDelegate:self];
    [personPickerView setDataSource:self];
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
    UIBarButtonItem *cancelChangesForEntirePaymentButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelChangesForEntirePayment:)];
    [[self navigationItem] setRightBarButtonItem:cancelChangesForEntirePaymentButton];
    [placeView setDelegate:self];
    payerViewPerson = [thisPayment payingPerson];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
