//
//  MCAddressBookDataReceiver.m
//  We all pay
//
//  Created by Mark Cornelisse on 28-05-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCAddressBookDataReceiver.h"

#import "MCWeAllPayStoreController.h"
#import "MCEmailAddress+addons.h"
#import "MCPerson+addons.h"
#import "MCSharedBill.h"

@implementation MCAddressBookDataReceiver

@synthesize delegate;
@synthesize thisPerson;
@synthesize tonightsBill;

#pragma mark - New in this class.

- (void)getPersonData:(ABRecordRef)person
{
    if (!thisPerson) {
        thisPerson = [MCPerson addPerson];
        if (tonightsBill) {
            [thisPerson addSharedBillObject:tonightsBill];
        }
    } 
    [thisPerson setThumbnailDataFromImage:[UIImage imageWithData:(__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail)]];
    [thisPerson setPictureDataFromImage:[UIImage imageWithData:(__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize)]];
    [thisPerson setFirstName:(__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty)];
    [thisPerson setLastName:(__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty)];
    ABMultiValueRef emailAddresses = ABRecordCopyValue(person, kABPersonEmailProperty);
    if (ABMultiValueGetCount(emailAddresses)) {
        for (NSUInteger i = 0; i < ABMultiValueGetCount(emailAddresses); i++) {
            NSString *emailAddressForPerson=(__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailAddresses, i);
            MCEmailAddress *emailAddressFound = [MCEmailAddress addEmailAddressFor:thisPerson];
            [emailAddressFound setEmailAddress:emailAddressForPerson];
            if (i == 0) {
                [emailAddressFound setSelected:[NSNumber numberWithBool:YES]];
            } else {
                [emailAddressFound setSelected:[NSNumber numberWithBool:NO]];
            }
        }
    } 
    CFRelease(emailAddresses);
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
    [viewController dismissViewControllerAnimated:YES completion:^{
        [[[viewController navigationItem] rightBarButtonItem] setEnabled:YES];
        [delegate receiveANewPersonFromAddressBook:thisPerson];
    }];
    thisPerson = nil;
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

@end
