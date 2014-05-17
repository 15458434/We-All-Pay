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
#import "MCSharedBill+addons.h"

@implementation MCAddressBookDataReceiver

@synthesize delegate;
@synthesize thisPerson;
@synthesize tonightsBill;

#pragma mark - New in this class.

- (void)getPersonData:(ABRecordRef)person
{
    // tonightsBill should be present.
    NSParameterAssert(tonightsBill);
    // Get all linked ABRecords from AddressBook
    CFArrayRef allLinkedPeople = ABPersonCopyArrayOfAllLinkedPeople(person);
    
    thisPerson = [delegate personRecordToUse];
    if (!thisPerson) {
        thisPerson = [tonightsBill addPerson];
    } else {
        [thisPerson deletAllEmailAddresses];
    }
    
    [thisPerson setThumbnailDataFromImage:[UIImage imageWithData:(__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail)]];
    [thisPerson setPictureDataFromImage:[UIImage imageWithData:(__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize)]];
    [thisPerson setFirstName:(__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty)];
    
    // Combine middle and Last name to create a name.
    NSString *middleName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (middleName) {
        [thisPerson setLastName:[NSString stringWithFormat:@"%@ %@", middleName, lastName]];
    } else {
        [thisPerson setLastName:lastName];
    }

    
    // Retrieve all possible mail addresses by going through the list of linked ABRecords and through the list of EmailAddresses.
    if (CFArrayGetCount(allLinkedPeople)) {
        for (NSUInteger j = 0 ; j < CFArrayGetCount(allLinkedPeople); j++) {
            ABRecordRef personRecord = CFArrayGetValueAtIndex(allLinkedPeople, j);
            ABMultiValueRef emailAddresses = ABRecordCopyValue(personRecord, kABPersonEmailProperty);
            if (ABMultiValueGetCount(emailAddresses)) {
                for (NSUInteger i = 0 ; i < ABMultiValueGetCount(emailAddresses); i++) {
                    NSString *emailAddressForPerson=(__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailAddresses, i);
                    [thisPerson addOneEmailAddressFromAString:emailAddressForPerson];
                }
            }
            CFRelease(emailAddresses);
        }
    }
    CFRelease(allLinkedPeople);
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
    [viewController dismissViewControllerAnimated:YES completion:^{
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"MCSharedBillMainViewController_iPad"];
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    }];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [viewController dismissViewControllerAnimated:YES completion:^{
        [[[viewController navigationItem] rightBarButtonItem] setEnabled:YES];
        [delegate receiveANewPersonFromAddressBook:thisPerson];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"MCSharedBillMainViewController_iPad"];
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    }];
    [self getPersonData:person];
    thisPerson = nil;
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

@end
