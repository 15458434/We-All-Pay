//
//  MCPersonViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 31-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPersonViewController.h"

#import "MCWeAllPayStoreController.h"
#import "MCPerson.h"
#import "MCSharedBill.h"

#import "MCTwoLabelsTitleView.h"

@interface MCPersonViewController ()

@end

@implementation MCPersonViewController

@synthesize tonightsBill;
@synthesize changeFlagDelegate;
@synthesize isNew;

#pragma mark - Actions

- (IBAction)dismissKeyboard:(id)sender
{
    if ([firstNameField isFirstResponder]) {
        [firstNameField endEditing:YES];
    }
    if ([lastNameField isFirstResponder]) {
        [lastNameField endEditing:YES];
    }
    if ([emailField isFirstResponder]) {
        [self cancelEmailPicker:self];
    }
}

- (void)cancelButtonPressed:(id)selector
{
    [[[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext] rollback];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)doneButtonPressed:(id)selector
{
    /*
    [[self changeFlagDelegate] sendDidSomethingChange:YES];
    [thisPerson setFirstName:firstName];
    [thisPerson setLastName:lastName];
    [thisPerson setEmailAddress:emailAddress];
    [thisPerson setAllEmailAddressesFromAddressBook:allEmailAddressesFromAddressBook];
    [thisPerson setPicture:picture];
    [thisPerson setThumbnail:thumbnail];
     */
    [[[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext] processPendingChanges];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)getSomeone:(id)selector
{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    if (!personReceiver) {
        personReceiver = [[MCAddressBookDataReceiver alloc] initWithViewController:self andDelegate:self];
        [personReceiver setThisPerson:thisPerson];
    }
    
    [peoplePicker setPeoplePickerDelegate:personReceiver];
    [self presentViewController:peoplePicker animated:YES completion:nil];
}

- (void)doneEmailPicker:(id)selector
{
    /*
    emailAddress = [allEmailAddressesFromAddressBook objectAtIndex:[emailSelectionFromAddressBookPickerView selectedRowInComponent:0]];
    [emailField resignFirstResponder];
    didSomethingChange = YES;
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
     */
}

- (void)cancelEmailPicker:(id)selector
{
    /*
    [emailField setText:[thisPerson emailAddress]];
    emailAddress = nil;
    [emailField resignFirstResponder];
     */
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    /*
    if (thisPersonHasPaidSomething) {
        if (textField == firstNameField || textField == lastNameField) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return YES;
    }
     */
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    /*
    if (textField == emailField) {
        // Set the UIPickerView as keyboard for the emailfield if Access to the AddressBook is authorized.
        if (kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus() && [thisPerson emailAddress]) {
            CGRect toolbarRect = CGRectMake(0, 0, [[self view] bounds].size.width, 44);
            UIToolbar *inputAccessoryPickerView = [[UIToolbar alloc] initWithFrame:toolbarRect];
            UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelEmailPicker:)];
            UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                        target:nil
                                                                                        action:nil];
            UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                        target:self
                                                                                        action:@selector(doneEmailPicker:)];
            NSArray *buttonArray = [[NSArray alloc] initWithObjects:cancelButton, flexButton, doneButton, nil];
            [inputAccessoryPickerView setItems:buttonArray animated:YES];
            if (!emailSelectionFromAddressBookPickerView) {
                emailSelectionFromAddressBookPickerView = [[UIPickerView alloc] init];
                [emailSelectionFromAddressBookPickerView setDelegate:self];
                [emailSelectionFromAddressBookPickerView setDataSource:self];
                [emailSelectionFromAddressBookPickerView setShowsSelectionIndicator:YES];
                [emailField setInputView:emailSelectionFromAddressBookPickerView];
                [emailField setInputAccessoryView:inputAccessoryPickerView];
            }
            UIToolbar *inputAccossoryNumberPad = [[UIToolbar alloc] initWithFrame:toolbarRect];
            cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                         target:self
                                                                         action:@selector(cancelNumberPad:)];
            doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                       target:self
                                                                       action:@selector(doneNumberPad:)];
            [inputAccossoryNumberPad setItems:[[NSArray alloc] initWithObjects:cancelButton, flexButton, doneButton, nil] animated:YES];
        }
    }
     */
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == firstNameField) {
        [thisPerson setFirstName:[firstNameField text]];
        didSomethingChange = YES;
        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
        return YES;
    } else if (textField == lastNameField) {
        [thisPerson setLastName:[lastNameField text]];
        didSomethingChange = YES;
        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    } else if (textField == emailField) {
        [thisPerson setEmailAddress:[emailField text]];
        didSomethingChange = YES;
        [emailField resignFirstResponder];
        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
        return YES;
    }
    return NO;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    // return [allEmailAddressesFromAddressBook objectAtIndex:row];
    return @"someone@earth";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //[emailField setText:[allEmailAddressesFromAddressBook objectAtIndex:row]];
    //[thisPerson emailAddress] = [emailField text];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    /*
    if (kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus()) {
        return [allEmailAddressesFromAddressBook count];
    } else {
        return 1;
    }
     */
    return 1;
}

#pragma mark - MCAddressBookReceiverDelegate

- (BOOL)isNewPersonFromAddressBookAlreadyPresent:(MCPerson *)newPerson
{
    // return [tonightsBill isPersonPresent:newPerson];
    return YES;
}

- (void)receiveANewPersonFromAddressBook:(MCPerson *)newPerson
{
    /*
    firstName = [newPerson firstName];
    lastName = [newPerson lastName];
    emailAddress = [newPerson emailAddress];
    allEmailAddressesFromAddressBook = [newPerson allEmailAddressesFromAddressBook];
    thumbnail = [newPerson thumbnail];
    picture = [newPerson picture];
    [newPerson removePictureData];
     */
    didSomethingChange = YES;
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    [emailSelectionFromAddressBookPickerView reloadComponent:0];
}

#pragma mark - New in this class

- (id)initWithPerson:(MCPerson *)person 
{
    self = [super init];
    
    if (self) {
        if (!person) {
            @throw [NSException exceptionWithName:@"nil" reason:@"person is nil" userInfo:nil];
        }
        thisPerson = person;
        didSomethingChange = NO;
    }
    return self;
}

#pragma mark - Inherited from super.

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
    
    if (!twoLabelTitleView) {
        twoLabelTitleView = [[[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil] objectAtIndex:0];
        if (isNew) {
            [[twoLabelTitleView mainLabel] setText:@"New person"];
            [[twoLabelTitleView subLabel] setText:@"Add new person"];
        } else {
            [[twoLabelTitleView mainLabel] setText:@"Person"];
            [[twoLabelTitleView subLabel] setText:@"Edit person"];
        }
        [[self navigationItem] setTitleView:twoLabelTitleView];
    }
    
    [[[self navigationItem] rightBarButtonItem] setEnabled:didSomethingChange];
    [addressBookButton setEnabled:!thisPersonHasPaidSomething];
    [[self navigationController] setToolbarHidden:NO animated:animated];
    [firstNameField setText:[thisPerson firstName]];
    [lastNameField setText:[thisPerson lastName]];
    [emailField setText:[thisPerson emailAddress]];
    NSNumber *moneySpendByThisPerson = [tonightsBill totalSumPaidBy:thisPerson];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [totalSumSpendLabel setText:[NSString stringWithFormat:@"Spent %@", [nf stringFromNumber:moneySpendByThisPerson]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Check to see if thisPerson has paid something.
    if ([tonightsBill hasPersonPaidSomething:thisPerson]) {
        thisPersonHasPaidSomething = YES;
    } else {
        thisPersonHasPaidSomething = NO;
    }
    
    if (kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus()) {
        addressBookButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(getSomeone:)];
        [addressBookButton setEnabled:!thisPersonHasPaidSomething];
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
        [self setToolbarItems:[NSArray arrayWithObjects:flexSpace, addressBookButton, nil] animated:NO];
    }
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(doneButtonPressed:)];
    [[self navigationItem] setRightBarButtonItem:doneButton];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(cancelButtonPressed:)];
    [[self navigationItem] setLeftBarButtonItem:cancelButton];
    [firstNameField setDelegate:self];
    [lastNameField setDelegate:self];
    [emailField setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
