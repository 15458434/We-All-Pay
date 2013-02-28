//
//  MCPersonViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 31-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPersonViewController.h"
#import "MCPerson.h"

@interface MCPersonViewController ()

@end

@implementation MCPersonViewController

#pragma mark - Actions

- (void)getSomeone:(id)selector
{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    [peoplePicker setPeoplePickerDelegate:self];
    [self presentViewController:peoplePicker animated:YES completion:nil];
}

- (void)doneEmailPicker:(id)selector
{
    [thisPerson setEmailAddress:[[thisPerson allEmailAddressesFromAddressBook] objectAtIndex:[emailSelectionFromAddressBookPickerView selectedRowInComponent:0]]];
    [emailField resignFirstResponder];
}

- (void)cancelEmailPicker:(id)selector
{
    [emailField setText:[thisPerson emailAddress]];
    [emailField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[thisPerson allEmailAddressesFromAddressBook] objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [emailField setText:[[thisPerson allEmailAddressesFromAddressBook] objectAtIndex:row]];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus()) {
        return [[thisPerson allEmailAddressesFromAddressBook] count];
    } else {
        return 1;
    }
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [self getPersonData:person];
    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
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
        
        if (kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus()) {
            UIBarButtonItem *addressBookButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(getSomeone:)];
            [[self navigationItem] setRightBarButtonItem:addressBookButton];
        }
    }
    return self;
}

- (void)getPersonData:(ABRecordRef)person
{
    [thisPerson setThumbnail:[UIImage imageWithData:(__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail)]];
    [thisPerson setPicture:[UIImage imageWithData:(__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize)]];
    [thisPerson setName:(__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty)];
    ABMultiValueRef emailAddresses = ABRecordCopyValue(person, kABPersonEmailProperty);
    if (ABMultiValueGetCount(emailAddresses)) {
        NSMutableArray *allEmailAddresses= [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < ABMultiValueGetCount(emailAddresses); i++) {
            NSString *emailAddressForArray=(__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailAddresses, i);
            [allEmailAddresses addObject:emailAddressForArray];
        }
        [thisPerson setEmailAddress:(__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailAddresses, 0)];
    } else {
        [thisPerson setEmailAddress:nil];
    }
    CFRelease(emailAddresses);
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
    
    [nameField setText:[thisPerson name]];
    [emailField setText:[thisPerson emailAddress]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the UIPickerView as keyboard for the emailfield if Access to the AddressBook is authorized.
    if (kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus()) {
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
        emailSelectionFromAddressBookPickerView = [[UIPickerView alloc] init];
        [emailSelectionFromAddressBookPickerView setDelegate:self];
        [emailSelectionFromAddressBookPickerView setDataSource:self];
        [emailField setInputView:emailSelectionFromAddressBookPickerView];
        [emailField setInputAccessoryView:inputAccessoryPickerView];
        
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
