//
//  MCPersonAddonsTest.m
//  We all pay
//
//  Created by Mark Cornelisse on 08-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCSharedBill+addons.h"
#import "MCPerson+CoreDataProperties.h"
#import "MCEmailAddress+CoreDataProperties.h"
#import "MCPayment+addons.h"
#import "MCExchangeRate+CoreDataProperties.h"
#import "MCPaymentPresence+CoreDataProperties.h"
#import "MCPerson+TestHelper.h"

#import "We_all_pay_Tests-Swift.h"

@interface MCPersonAddonsTest : XCTestCase

@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation MCPersonAddonsTest

- (void)setUp {
    [super setUp];
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSError *error;
    NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error];
    XCTAssertTrue(persistentStore, @"Something went wrong opening the In Memory Store: %@", [error localizedDescription]);
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _context.persistentStoreCoordinator = persistentStoreCoordinator;}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMCPersonAddonsAddAndDeleteEmailAddress
{
    MCPerson *thisPerson = [[MCPerson alloc] initWithContext:_context];
    MCPersonModel *model = [[MCPersonModel alloc] initWithPerson:thisPerson];
    [model.person setFirstName:@"Mark"];
    [model.person setLastName:@"Cornelisse"];
    NSString *emailAddressMark = @"info@markcornelisse.nl";
    [model addOneEmailAddressFromAString:emailAddressMark];
    XCTAssertTrue(thisPerson.hasEmailAddress, @"There is no emailAddress present when one had just been added.");
    XCTAssertTrue([thisPerson.defaultEmailAddress isEqualToString:emailAddressMark], @"emailAddress Stored is not equal to the new default one");
    NSString *emailAddress2Mark = @"mark.cornelisse@yahoo.com";
    [model addOneEmailAddressFromAString:emailAddress2Mark];
    XCTAssertTrue(thisPerson.hasEmailAddress, @"There is no emailAddress present when two has been added.");
    XCTAssertTrue([[thisPerson defaultEmailAddress] isEqualToString:emailAddressMark], @"emailAddress Stored is not equal to the first one");
    [model addOneEmailAddressFromAString:emailAddress2Mark];
    XCTAssertTrue([[thisPerson emailAddress] count] == 2, @"Adding two times the same emailAddress is possible.");
    NSString *emailAddress3Mark = @"m.p.cornelisse@gmail.com";
    [model addNewDefaultEmailAddressFromAString:emailAddress3Mark];
    XCTAssertTrue([[thisPerson defaultEmailAddress] isEqualToString:emailAddress3Mark], @"addNewDefaultEmailAddress failes to set the right defaultEmailAddress");

    NSInteger i = 0;
    for (MCEmailAddress *email in [thisPerson emailAddress]) {
        if (email.selected.boolValue) {
            i++;
        }
    }
    XCTAssertTrue(i == 1, @"Only one emailaddress should have be default.");
    XCTAssertTrue([[thisPerson emailAddress] count] == 3, @"All emailAddresses have been entered.");
    
    MCPersonModel *personModel = [[MCPersonModel alloc] init];
    [personModel prepareForUseWithPerson:thisPerson];
    MCEmailAddress *toBeDeletedEmailAddress = personModel.defaultEmailaddress;
    [personModel deleteEmailAddress:toBeDeletedEmailAddress];
    XCTAssertTrue([[thisPerson emailAddress] count] == 2, @"Different amount of emailAddresses then expected.");
    XCTAssertTrue(thisPerson.defaultEmailAddressObject, @"No new defaultEmailAddress present");
    //XCTAssertFalse([MCEmailAddress isTableInDatabaseEmpty], @"No emailAddresses left in the database.");
    [personModel deleteAllEmailAddresses];
    //XCTAssertTrue([MCEmailAddress isTableInDatabaseEmpty], @"Email addresses left in the database.");
    XCTAssertFalse(thisPerson.hasEmailAddress, @"There is an emailAddress present when two has been added.");
    XCTAssertFalse([MCPerson isTableInDatabaseEmptyForManagedObjectContext: _context], @"No people left in the database");
    [_context deleteObject:personModel.person];
    XCTAssertTrue([thisPerson isDeleted], @"This person will be deleted at the next save.");
}

- (void)testSetNewDefaultEmailaddressObject
{
    MCPerson *thisPerson = [[MCPerson alloc] initWithContext:_context];
    MCPersonModel *markModel = [[MCPersonModel alloc] initWithPerson:thisPerson];
    [thisPerson setFirstName:@"Mark"];
    [thisPerson setLastName:@"Cornelisse"];
    
    NSString *emailAddressMark = @"info@markcornelisse.nl";
    [markModel addOneEmailAddressFromAString:emailAddressMark];
    XCTAssertTrue(thisPerson.hasEmailAddress, @"There is no emailAddress present when one had just been added.");
    XCTAssertTrue([[thisPerson defaultEmailAddress] isEqualToString:emailAddressMark], @"emailAddress Stored is not equal to the new default one");
    MCEmailAddress *firstEmailAddressObject = thisPerson.defaultEmailAddressObject;
    XCTAssertTrue([[firstEmailAddressObject emailAddress] isEqualToString:emailAddressMark], @"Emailaddress stored is not the one retrieved.");
    NSString *emailAddress2Mark = @"mark.cornelisse@yahoo.com";
    [markModel addOneEmailAddressFromAString:emailAddress2Mark];
    XCTAssertTrue(thisPerson.hasEmailAddress, @"There is no emailAddress present when two has been added.");
    XCTAssertTrue([[thisPerson defaultEmailAddress] isEqualToString:emailAddressMark], @"emailAddress Stored is not equal to the first one");
    [markModel addOneEmailAddressFromAString:emailAddress2Mark];
    XCTAssertTrue([[thisPerson emailAddress] count] == 2, @"Adding two times the same emailAddress is possible.");
    NSString *emailAddress3Mark = @"m.p.cornelisse@gmail.com";
    [markModel addNewDefaultEmailAddressFromAString:emailAddress3Mark];
    XCTAssertTrue([[thisPerson defaultEmailAddress] isEqualToString:emailAddress3Mark], @"addNewDefaultEmailAddress failes to set the right defaultEmailAddress");
    [markModel updateDefaultEmailAddressObject:firstEmailAddressObject];
    XCTAssertTrue([[thisPerson defaultEmailAddress] isEqualToString:emailAddressMark], @"setNewDefaultEmailaddressObject failes to set the correct defaultEmailAddress");
    MCPersonModel *personModel = [[MCPersonModel alloc] init];
    [personModel prepareForUseWithPerson:thisPerson];
    [personModel deleteAllEmailAddresses];
    [_context deleteObject:personModel.person];
}

- (void)testHasPersonMadePaymentWithInvalidExchangeRates
{
    MCSharedBill *tonightsBill = [MCSharedBill addSharedBillToContext:_context];
    MCPerson *mark = [tonightsBill addPerson];
    MCPayment *thisPayment = [tonightsBill addPayment];
    thisPayment.payingPerson = mark;
    thisPayment.exchangeRate.status = [NSNumber numberWithShort:MCExchangeRateStatusValid];
    XCTAssertFalse([mark hasPersonMadePaymentWithInvalidExchangeRates], @"All payments person has made should be valid.");
    thisPayment.exchangeRate.status = [NSNumber numberWithShort:MCExchangeRateStatusInvalid];
    XCTAssertTrue([mark hasPersonMadePaymentWithInvalidExchangeRates], @"No payment should be valid.");
    thisPayment.exchangeRate.status = [NSNumber numberWithShort:MCExchangeRateStatusFetching];
    XCTAssertTrue([mark hasPersonMadePaymentWithInvalidExchangeRates], @"No payment should be valid.");
}

- (void)testTotalSumPaidBy
{
    MCSharedBill *tonightsBill = [MCSharedBill addSharedBillToContext:_context];
    MCPerson *fred = [tonightsBill addPerson];
    fred.firstName = @"Fred";
    MCPerson *anna = [tonightsBill addPerson];
    anna.firstName = @"Marieke";
    MCPayment *drinks = [tonightsBill addPayment];
    drinks.payingPerson = fred;
    drinks.money = @(10);
    drinks.descriptionOfPayment = @"coffee";
    NSNumber *totalPaidByFred = fred.totalSumPaid;
    XCTAssertEqualWithAccuracy(@(10).doubleValue, totalPaidByFred.doubleValue, 0.001);
    
    // Test with missing no payment presence
    MCPayment *tickets = [tonightsBill addPayment];
    tickets.payingPerson = anna;
    tickets.money = @(20);
    for (MCPaymentPresence *presence in tickets.peopleSharingPayment) {
        presence.isPersonPresent = @NO;
    }
    XCTAssertEqualWithAccuracy(@(10).doubleValue, fred.totalSumPaid.doubleValue, 0.001);
    XCTAssertEqualWithAccuracy(@(20).doubleValue, anna.totalSumPaid.doubleValue, 0.001);
}

@end
