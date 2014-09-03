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

- (void)importPersonDataAndSave:(ABRecordRef)person
{
    // tonightsBill should be present.
    NSParameterAssert(_tonightsBill);
    NSManagedObjectID *tonightsBillID = [_tonightsBill objectID];
    
    ABRecordID personID = ABRecordGetRecordID(person);
    
    NSManagedObjectContext *backgroundContext = [[MCWeAllPayStoreController defaultStore] backgroundThreadContext];
    [backgroundContext performBlock:^{
        _writableTonightsBill = (MCSharedBill *)[backgroundContext objectWithID:tonightsBillID];
        NSParameterAssert(_writableTonightsBill);
        
        CFErrorRef error = NULL;
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
        if (error) {
            NSError *addressBookError = (__bridge_transfer NSError *)error;
            NSLog(@"Unable to open addressBook: %@", addressBookError);
        }
        
        ABRecordRef personInBackground = ABAddressBookGetPersonWithRecordID(addressBookRef, personID);
        
        // Get all linked ABRecords from AddressBook
        CFArrayRef allLinkedPeople = ABPersonCopyArrayOfAllLinkedPeople(personInBackground);
        
        thisPerson = [_writableTonightsBill addPerson];
        
        [thisPerson setThumbnailDataFromImage:[UIImage imageWithData:(__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(personInBackground, kABPersonImageFormatThumbnail)]];
        [thisPerson setPictureDataFromImage:[UIImage imageWithData:(__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(personInBackground, kABPersonImageFormatOriginalSize)]];
        [thisPerson setFirstName:(__bridge_transfer NSString *)ABRecordCopyValue(personInBackground, kABPersonFirstNameProperty)];
        
        // Combine middle and Last name to create a name.
        NSString *middleName = (__bridge_transfer NSString *)ABRecordCopyValue(personInBackground, kABPersonMiddleNameProperty);
        NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(personInBackground, kABPersonLastNameProperty);
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
        [[MCWeAllPayStoreController defaultStore] savebackgroundContext];
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
//        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//        [tracker set:kGAIScreenName value:@"MCSharedBillMainViewController_iPad"];
//        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    }];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    // iOS 8 code
    [viewController dismissViewControllerAnimated:YES completion:^{
        [delegate receiveANewPersonFromAddressBook:thisPerson];
    }];
    [self importPersonDataAndSave:person];
}
#endif

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    // iOS 7 code
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 80000
    [viewController dismissViewControllerAnimated:YES completion:^{
//        [[[viewController navigationItem] rightBarButtonItem] setEnabled:YES];
        [delegate receiveANewPersonFromAddressBook:thisPerson];
//        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//        [tracker set:kGAIScreenName value:@"MCSharedBillMainViewController_iPad"];
//        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    }];
    [self importPersonDataAndSave:person];
#endif
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

@end
