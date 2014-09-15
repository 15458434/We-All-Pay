//
//  MCPersonAddonsTest.m
//  We all pay
//
//  Created by Mark Cornelisse on 08-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"
#import "MCEmailAddress+addons.h"
#import "MCPayment+addons.h"
#import "MCExchangeRate+addons.h"

@interface MCPersonAddonsTest : XCTestCase
{
    MCWeAllPayStoreController *mainController;
}

@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation MCPersonAddonsTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    mainController = [MCWeAllPayStoreController defaultStore];
    _context = [mainController mainThreadContext];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMCPersonAddonsAddAndDeleteEmailAddress
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
    [thisPerson addOneEmailAddressFromAString:emailAddress2Mark];
    XCTAssertTrue([[thisPerson emailAddress] count] == 2, @"Adding two times the same emailAddress is possible.");
    NSString *emailAddress3Mark = @"m.p.cornelisse@gmail.com";
    [thisPerson addNewDefaultEmailAddressFromAString:emailAddress3Mark];
    XCTAssertTrue([[thisPerson defaultEmailAddress] isEqualToString:emailAddress3Mark], @"addNewDefaultEmailAddress failes to set the right defaultEmailAddress");
    
    // Create a fetch request for MCEmailAddress
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCEmailAddress"];
    
    // Select only emailAddresses for person
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"owner = %@", thisPerson];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"selected = %@", @YES];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1, predicate2]];
    [request setPredicate:compoundPredicate];
    NSError *error;
    NSArray *emailAddresses;
    emailAddresses = [_context executeFetchRequest:request error:&error];
    if (!emailAddresses) {
        XCTFail(@"No list of email addresses generated");
    }
    XCTAssertTrue([emailAddresses count] == 1, @"More or less then one defaulEmailAddress present.");
    XCTAssertTrue([[thisPerson emailAddress] count] == 3, @"All emailAddresses have been entered.");
    
    MCEmailAddress *toBeDeletedEmailAddress = [thisPerson getDefaultEmailAddressObject];
    [thisPerson deleteEmailAddress:toBeDeletedEmailAddress];
    XCTAssertTrue([[thisPerson emailAddress] count] == 2, @"Different amount of emailAddresses then expected.");
    XCTAssertTrue([thisPerson getDefaultEmailAddressObject], @"No new defaultEmailAddress present");
    //XCTAssertFalse([MCEmailAddress isTableInDatabaseEmpty], @"No emailAddresses left in the database.");
    [thisPerson deletAllEmailAddresses];
    //XCTAssertTrue([MCEmailAddress isTableInDatabaseEmpty], @"Email addresses left in the database.");
    XCTAssertFalse([thisPerson isThereAnEmailAddress], @"There is an emailAddress present when two has been added.");
    
    XCTAssertFalse([MCPerson isTableInDatabaseEmpty], @"No people left in the database");
    [MCPerson deletePerson:thisPerson];
    XCTAssertTrue([thisPerson isDeleted], @"This person will be deleted at the next save.");
}

- (void)testSetNewDefaultEmailaddressObject
{
    MCPerson *thisPerson = [MCPerson addPerson];
    [thisPerson setFirstName:@"Mark"];
    [thisPerson setLastName:@"Cornelisse"];
    NSString *emailAddressMark = @"info@markcornelisse.nl";
    [thisPerson addOneEmailAddressFromAString:emailAddressMark];
    XCTAssertTrue([thisPerson isThereAnEmailAddress], @"There is no emailAddress present when one had just been added.");
    XCTAssertTrue([[thisPerson defaultEmailAddress] isEqualToString:emailAddressMark], @"emailAddress Stored is not equal to the new default one");
    MCEmailAddress *firstEmailAddressObject = [thisPerson getDefaultEmailAddressObject];
    XCTAssertTrue([[firstEmailAddressObject emailAddress] isEqualToString:emailAddressMark], @"Emailaddress stored is not the one retrieved.");
    NSString *emailAddress2Mark = @"mark.cornelisse@yahoo.com";
    [thisPerson addOneEmailAddressFromAString:emailAddress2Mark];
    XCTAssertTrue([thisPerson isThereAnEmailAddress], @"There is no emailAddress present when two has been added.");
    XCTAssertTrue([[thisPerson defaultEmailAddress] isEqualToString:emailAddressMark], @"emailAddress Stored is not equal to the first one");
    [thisPerson addOneEmailAddressFromAString:emailAddress2Mark];
    XCTAssertTrue([[thisPerson emailAddress] count] == 2, @"Adding two times the same emailAddress is possible.");
    NSString *emailAddress3Mark = @"m.p.cornelisse@gmail.com";
    [thisPerson addNewDefaultEmailAddressFromAString:emailAddress3Mark];
    XCTAssertTrue([[thisPerson defaultEmailAddress] isEqualToString:emailAddress3Mark], @"addNewDefaultEmailAddress failes to set the right defaultEmailAddress");
    [thisPerson setNewDefaultEmailaddressObject:firstEmailAddressObject];
    XCTAssertTrue([[thisPerson defaultEmailAddress] isEqualToString:emailAddressMark], @"setNewDefaultEmailaddressObject failes to set the correct defaultEmailAddress");
    [thisPerson deletAllEmailAddresses];
    [MCPerson deletePerson:thisPerson];
}

- (void)testHasPersonMadePaymentWithInvalidExchangeRates
{
    MCSharedBill *tonightsBill = [MCSharedBill addSharedBillToContext:_context];
    MCPerson *mark = [tonightsBill addPerson];
    MCPayment *thisPayment = [tonightsBill addPayment];
    thisPayment.payingPerson = mark;
    thisPayment.exchangeRate.status = [NSNumber numberWithShort:valid];
    XCTAssertFalse([mark hasPersonMadePaymentWithInvalidExchangeRates], @"All payments person has made should be valid.");
    thisPayment.exchangeRate.status = [NSNumber numberWithShort:invalid];
    XCTAssertTrue([mark hasPersonMadePaymentWithInvalidExchangeRates], @"No payment should be valid.");
    thisPayment.exchangeRate.status = [NSNumber numberWithShort:fetching];
    XCTAssertTrue([mark hasPersonMadePaymentWithInvalidExchangeRates], @"No payment should be valid.");
}

@end
