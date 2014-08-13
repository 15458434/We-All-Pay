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

#pragma mark - New in this class.

- (void)getPersonData:(ABRecordRef)person
{
    // tonightsBill should be present.
    NSParameterAssert(_tonightsBill);
    
    // Get all linked ABRecords from AddressBook
    CFArrayRef allLinkedPeople = ABPersonCopyArrayOfAllLinkedPeople(person);
    
    NSData *thumbnailData = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
    NSData *pictureData = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize);
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    // Combine middle and Last name to create a name.
    NSString *middleName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    NSMutableSet *emailAddressesSet = [NSMutableSet new];
    
    // Retrieve all possible mail addresses by going through the list of linked ABRecords and through the list of EmailAddresses.
    if (CFArrayGetCount(allLinkedPeople)) {
        for (NSUInteger j = 0 ; j < CFArrayGetCount(allLinkedPeople); j++) {
            ABRecordRef personRecord = CFArrayGetValueAtIndex(allLinkedPeople, j);
            ABMultiValueRef emailAddresses = ABRecordCopyValue(personRecord, kABPersonEmailProperty);
            if (ABMultiValueGetCount(emailAddresses)) {
                for (NSUInteger i = 0 ; i < ABMultiValueGetCount(emailAddresses); i++) {
                    NSString *emailAddressForPerson=(__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailAddresses, i);
                    [emailAddressesSet addObject:emailAddressForPerson];
                }
            }
            CFRelease(emailAddresses);
        }
    }
    CFRelease(allLinkedPeople);
    
    NSManagedObjectContext *backgroundContext = [[MCWeAllPayStoreController defaultStore] backgroundThreadContext];
    [backgroundContext performBlock:^{
        
        _writableThisPerson = [_writableTonightsBill addPerson];
        
        _writableThisPerson.firstName = firstName;
        if (middleName) {
            _writableThisPerson.lastName = [NSString stringWithFormat:@"%@ %@", middleName, lastName];
        } else {
            _writableThisPerson.lastName = lastName;
        }
        
        for (NSString *emailString in emailAddressesSet) {
            [_writableThisPerson addOneEmailAddressFromAString:emailString];
        }
        
        [_writableThisPerson setThumbnailData:thumbnailData];
        [_writableThisPerson setPictureData:pictureData];
        
        [[MCWeAllPayStoreController defaultStore] saveStore];
    }];
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
//        [[[viewController navigationItem] rightBarButtonItem] setEnabled:YES];
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
