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
    if ([placeView isFirstResponder]) {
        [placeView endEditing:YES];
        [placeView setText:[thisPayment descriptionOfPayment]];
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

    if ([payerView isFirstResponder]) {
        [self donePersonPicker:self];
    }
    if ([paidView isFirstResponder]) {
        [self doneNumberPad:self];
    }
    if ([placeView isFirstResponder]) {
        [self storePlaceViewData];
    }
    NSLog(@"MCPaymentViewController: Done button pressed.");
    if (didSomethingChange) {
        NSManagedObjectContext *context = [[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext];
        [context performBlock:^{
            NSError *error;
            [context save:&error];
            if (error) {
                NSLog(@"Error saving: %@", [error localizedDescription]);
            }
        }];
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void)removePayment:(id)selector
{
    NSLog(@"removePayment is being executed.");
    /*
    [[self delegate] removePayment:thisPayment fromPaymentViewController:self];
    [[self navigationController] popViewControllerAnimated:YES];
     */
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
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
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
    /*
    if (isNew) {
        [[self delegate] removePayment:thisPayment fromPaymentViewController:self];
    }
    [[self navigationController] popViewControllerAnimated:YES];
     */
}

- (void)storePlaceViewData
{
    [placeView resignFirstResponder];
    [thisPayment setDescriptionOfPayment:[placeView text]];
    didSomethingChange = YES;
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
}

- (void)storeMoneySpent
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    // [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    // [nf setLocale:[NSLocale currentLocale]];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    [thisPayment setMoney:[nf numberFromString:[paidView text]]];
    
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [paidView setText:[nf stringFromNumber:[thisPayment money]]];
    
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
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
    return [[listOfPeople objectAtIndex:row] getFullName];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [payerView setText:[[listOfPeople objectAtIndex:row] getFullName]];
}

#pragma mark - PickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ALL sharedBill = %@", tonightsBill];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"getFullName" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext];
    __block NSArray *result;
    [context performBlockAndWait:^{
        NSError *error;
        result = [context executeFetchRequest:request error:&error];
        if (!result) {
            NSLog(@"An error occured during fetching people on this sharedBill: %@", [error localizedDescription]);
        }
    }];
    
    return [result count];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == placeView) {
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
        if (didSomethingChange) {
            [paidView setText:[nf stringFromNumber:paidViewNumber]];
        } else {
            [paidView setText:[nf stringFromNumber:[thisPayment money]]];
        }
    }
    
    if (textField == payerView) {
        NSInteger row = 0;
        if ([thisPayment payingPerson]) {
            row = [listOfPeople indexOfObject:[thisPayment payingPerson]];
        } else {
            row = [personPickerView selectedRowInComponent:0];
        }
        [thisPayment setPayingPerson:[listOfPeople objectAtIndex:row]];
        [payerView setText:[[thisPayment payingPerson] getFullName]];
        [personPickerView selectRow:row inComponent:0 animated:YES];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([payerView isFirstResponder] || [paidView isFirstResponder] || [placeView isFirstResponder]) {
        switchInputField = YES;
        return YES;
    } else {
        switchInputField = NO;
        return YES;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == paidView) {
        if (switchInputField) {
            [self storeMoneySpent];
            switchInputField = NO;
        }
    } else if (textField == payerView) {
        if (switchInputField) {
            [self donePersonPicker:self];
            switchInputField = NO;
        }
    } else if (textField == placeView) {
        // Do something to store value of placeview.
        if (switchInputField) {
            [self storePlaceViewData];
            switchInputField = NO;
        }
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
    if (!twoLabelTitleView) {
        twoLabelTitleView = [[[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil] objectAtIndex:0];
        if (isNew) {
            [[twoLabelTitleView mainLabel] setText:@"New payment"];
            [[twoLabelTitleView subLabel] setText:@"Add payment data"];
        } else {
            [[twoLabelTitleView mainLabel] setText:@"Payment"];
            [[twoLabelTitleView subLabel] setText:@"Edit payment data"];
        }
        [[self navigationItem] setTitleView:twoLabelTitleView];
    }
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                               target:self
                                                               action:@selector(backButtonPressed:)];
    if (![[self navigationItem] rightBarButtonItem]) {
        [[self navigationItem] setRightBarButtonItem:doneButton];
    }
    [[[self navigationItem] rightBarButtonItem] setEnabled:didSomethingChange];
    cancelChangesForEntirePaymentButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelChangesForEntirePayment:)];
    [[self navigationItem] setLeftBarButtonItem:cancelChangesForEntirePaymentButton];
    
    // Fill in the form if data is present.
    [payerView setText:[[thisPayment payingPerson] getFullName]];
    [payerView setDelegate:self];
    [placeView setText:[thisPayment descriptionOfPayment]];
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
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                               target:self
                                                               action:@selector(doneNumberPad:)];
    [inputAccossoryNumberPad setItems:[[NSArray alloc] initWithObjects:cancelButton, flexButton, doneButton, nil] animated:YES];
    [paidView setInputAccessoryView:inputAccossoryNumberPad];
    [paidView setDelegate:self];

    [placeView setDelegate:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
