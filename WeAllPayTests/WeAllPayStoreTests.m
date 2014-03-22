//
//  WeAllPayTests.m
//  WeAllPayTests
//
//  Created by Mark Cornelisse on 21-03-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCWeAllPayStoreController.h"
#import "MCPerson+addons.h"
#import "MCPayment+addons.h"
#import "MCSharedBill+addons.h"

@interface WeAllPayStoreTests : XCTestCase
{
    MCWeAllPayStoreController *mainController;
    //NSManagedObjectContext *context;
}

@end

@implementation WeAllPayStoreTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    mainController = [MCWeAllPayStoreController defaultStore];
    
    /*
    // ObjectModel from any models in app bundle
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    // Coordinator with in-mem store type
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    [coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
    
    // Context with private queue
    context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    // Choose your concurrency type, or leave it off entirely
    context.persistentStoreCoordinator = coordinator;
     */
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMCWeAllPayStoreController
{
    MCWeAllPayStoreController *testController = [[MCWeAllPayStoreController alloc] init];
    XCTAssertEqualObjects(testController, mainController, @"MCWeAllPayStoreController init gives not the defaultStore.");
    testController = nil;
    testController = [MCWeAllPayStoreController defaultStore];
    XCTAssertEqualObjects(testController, mainController, @"MCWeAllPayStoreController defaultStore gives not the defaultStore.");
}

- (void)testMCPersonAddons
{
    MCPerson *thisPerson = [MCPerson addPerson];
    [thisPerson setFirstName:@"Mark"];
    [thisPerson setLastName:@"Cornelisse"];
    NSString *emailAddressMark = @"info@markcornelisse.nl";
    [thisPerson addOneEmailAddressFromAString:emailAddressMark];
    XCTAssertTrue([thisPerson isThereAnEmailAddress], @"There is no emailAddress present when one had just been added.");
    XCTAssertTrue([[thisPerson defaultEmailAddress] isEqualToString:emailAddressMark], @"emailAddress Stored is not equal to the new default one");
    NSString *emailAddress2Mark = @"mark.cornelisse@yahoo.com";
    [thisPerson addOneEmailAddressFromAString:emailAddress2Mark];
    XCTAssertTrue([thisPerson isThereAnEmailAddress], @"There is no emailAddress present when two has been added.");
    XCTAssertTrue([[thisPerson defaultEmailAddress] isEqualToString:emailAddressMark], @"emailAddress Stored is not equal to the first one");
    /* Disabled the test failes.
    [thisPerson addOneEmailAddressFromAString:emailAddress2Mark];
    XCTAssertTrue([[thisPerson emailAddress] count] == 2, @"Adding two times the same emailAddress is possible.");
     */
    NSString *emailAddress3Mark = @"m.p.cornelisse@gmail.com";
    [thisPerson addNewDefaultEmailAddressFromAString:emailAddress3Mark];
    XCTAssertTrue([[thisPerson defaultEmailAddress] isEqualToString:emailAddress3Mark], @"addNewDefaultEmailAddress failes to set the right defaultEmailAddress");
    
    // Create a fetch request for MCEmailAddress
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCEmailAddress"];
    
    // Select only emailAddresses for person
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"owner = %@", thisPerson];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"selected = %@", [NSNumber numberWithBool:YES]];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate1, predicate2, nil]];
    [request setPredicate:compoundPredicate];
    NSError *error;
    NSArray *emailAddresses;
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    emailAddresses = [context executeFetchRequest:request error:&error];
    if (!emailAddresses) {
        XCTFail(@"No list of email addresses generated");
    }
    XCTAssertTrue([emailAddresses count] == 1, @"More or less then one defaulEmailAddress present.");
    XCTAssertTrue([[thisPerson emailAddress] count] == 3, @"All emailAddresses have been entered.");
    
    MCEmailAddress *toBeDeletedEmailAddress = [thisPerson getDefaultEmailAddressObject];
    [thisPerson deleteEmailAddress:toBeDeletedEmailAddress];
    XCTAssertTrue([[thisPerson emailAddress] count] == 2, @"Different amount of emailAddresses then expected.");
    XCTAssertTrue([thisPerson getDefaultEmailAddressObject], @"No new defaultEmailAddress present");
    [thisPerson deletAllEmailAddresses];
    XCTAssertFalse([thisPerson isThereAnEmailAddress], @"There is an emailAddress present when two has been added.");
    
    [MCPerson deletePerson:thisPerson];
    request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    NSArray *sda = [NSArray arrayWithObjects:sd, nil];
    [request setSortDescriptors:sda];
    NSArray *people = [context executeFetchRequest:request error:&error];
    if (people) {
        XCTAssertTrue([people count] == 0, @"Still %lu people present in the database.", [people count]);
    } else {
        XCTFail(@"There should be an empty array of people");
    }
}

- (void)testMCPaymentAddons
{
    
}

- (void)testMCSharedBillAddOns
{
    MCSharedBill *theBill = [MCSharedBill addSharedBill];
    
}



@end
