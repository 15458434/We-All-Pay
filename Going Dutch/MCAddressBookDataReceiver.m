//
//  MCAddressBookDataReceiver.m
//  We all pay
//
//  Created by Mark Cornelisse on 28-05-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCAddressBookDataReceiver.h"
#import "MCPerson.h"

@implementation MCAddressBookDataReceiver

@synthesize delegate;

#pragma mark - New in this class.

- (void)getPersonData:(ABRecordRef)person
{
    editedPerson = [[MCPerson alloc] init];
    [editedPerson setThumbnail:[UIImage imageWithData:(__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail)]];
    [editedPerson setPicture:[UIImage imageWithData:(__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize)]];
    [editedPerson setFirstName:(__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty)];
    [editedPerson setLastName:(__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty)];
    ABMultiValueRef emailAddresses = ABRecordCopyValue(person, kABPersonEmailProperty);
    if (ABMultiValueGetCount(emailAddresses)) {
        NSMutableArray *allEmailAddresses= [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < ABMultiValueGetCount(emailAddresses); i++) {
            NSString *emailAddressForArray=(__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailAddresses, i);
            [allEmailAddresses addObject:emailAddressForArray];
            [editedPerson setAllEmailAddressesFromAddressBook:allEmailAddresses];
        }
        [editedPerson setEmailAddress:(__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailAddresses, 0)];
    } else {
        [editedPerson setEmailAddress:nil];
    }
    CFRelease(emailAddresses);
    [delegate receiveANewPersonFromAddressBook:editedPerson];
}

#pragma mark - Inherited from super.

- (id) init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithDelegate:(id)delegateUsedOnInit
{
    self = [super init];
    if (self) {
        delegate = delegateUsedOnInit;
    }
    return self;
}

- (id)initWithViewController:(UIViewController *)newViewController andDelegate:(id)newDelegate
{
    self = [super init];
    if (self) {
        delegate = newDelegate;
        viewController = newViewController;
    }
    return self;
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [self getPersonData:person];
    [[[viewController navigationItem] rightBarButtonItem] setEnabled:YES];
    [viewController dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

@end
