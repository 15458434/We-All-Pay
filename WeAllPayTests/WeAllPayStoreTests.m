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
#import "MCEmailAddress+addons.h"
#import "MCReturnPayment.h"

@interface WeAllPayStoreTests : XCTestCase
{
    MCWeAllPayStoreController *mainController;
    NSManagedObjectContext *context;
}

@end

@implementation WeAllPayStoreTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    mainController = [MCWeAllPayStoreController defaultStore];
    context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
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

- (void)testMCPersonAddonsGetName
{
    MCPerson *thisPerson = [MCPerson addPerson];
    [thisPerson setFirstName:@"Connie"];
    [thisPerson setLastName:@"Carter"];
    [thisPerson addOneEmailAddressFromAString:@"connie@markcornelisse.nl"];
    XCTAssertTrue([[thisPerson getName] isEqualToString:@"Connie"], @"First name is not selected when it's available.");
    XCTAssertTrue([[thisPerson getFullName] isEqualToString:@"Connie Carter"]);
    MCPerson *thisPersonWithMissingFirstName = [MCPerson addPerson];
    [thisPersonWithMissingFirstName setLastName:@"Carter"];
    [thisPersonWithMissingFirstName addOneEmailAddressFromAString:@"connie@markcornelisse.nl"];
    XCTAssertTrue([[thisPersonWithMissingFirstName getName] isEqualToString:@"Carter"], @"Last is not selected when first name is not available");
    XCTAssertTrue([[thisPersonWithMissingFirstName getFullName] isEqualToString:@"Carter"], @"Fullname is wrong when first name is missing.");
    MCPerson *thisPersonWithMissingFirstAndLastName = [MCPerson addPerson];
    [thisPersonWithMissingFirstAndLastName addOneEmailAddressFromAString:@"connie@markcornelisse.nl"];
    XCTAssertTrue([[thisPersonWithMissingFirstAndLastName getName] isEqualToString:@"connie@markcornelisse.nl"], @"emailAddress is not selected when both first and lastname are not selected.");
    XCTAssertTrue([[thisPersonWithMissingFirstAndLastName getFullName] isEqualToString:@"connie@markcornelisse.nl"], @"emailAddress is not selected when both first and lastnames are not selected.");
}

- (void)testPersonExistenceOnSharedBill
{
    MCSharedBill *sharedbill = [MCSharedBill addSharedBill];
    MCPerson *mark = [sharedbill addPerson];
    [mark setFirstName:@"Mark"];
    [mark setLastName:@"Cornelisse"];
    [mark addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    [mark addOneEmailAddressFromAString:@"support@markcornelisse.nl"];
    [mark addNewDefaultEmailAddressFromAString:@"m.p.cornelisse@gmail.com"];
    XCTAssertEqualObjects(@"m.p.cornelisse@gmail.com", [mark defaultEmailAddress], @"Default emailAddress is not right.");
    NSString *markFirstName = @"Mark";
    NSString *markLastName = @"Cornelisse";
    NSString *markDefaultEmailAddress = @"m.p.cornelisse@gmail.com";
    XCTAssertTrue([sharedbill isPresentWithFirstName:markFirstName andLastName:markLastName andEmailAddress:markDefaultEmailAddress], @"Person is not present.");
    NSString *ilseFirstName = @"Ilse";
    NSString *ilseLastName = @"Béguin";
    NSString *ilseDefaultEmailAddress = @"ilse.beguin@hotmail.com";
    XCTAssertFalse([sharedbill isPresentWithFirstName:ilseFirstName andLastName:ilseLastName andEmailAddress:ilseDefaultEmailAddress], @"Person is present.");
}


- (void)testGetPeopleOnSharedBill
{
    MCSharedBill *tonightsBill = [MCSharedBill addSharedBill];
    NSArray *bazinga = [[MCWeAllPayStoreController defaultStore] getPeopleOnSharedBill:tonightsBill];
    XCTAssertTrue([bazinga count] == 0, @"Aantal mensen op the shared Bill klopt niet.");
    MCPerson *thisPerson = [tonightsBill addPerson];
    [thisPerson setFirstName:@"Mark"];
    bazinga = [[MCWeAllPayStoreController defaultStore] getPeopleOnSharedBill:tonightsBill];
    XCTAssertTrue([bazinga count] == 1, @"Aantal mensen op the shared Bill klopt niet.");
    MCPerson *thisPerson2 = [tonightsBill addPerson];
    [thisPerson2 setFirstName:@"Ilse"];
    bazinga = [[MCWeAllPayStoreController defaultStore] getPeopleOnSharedBill:tonightsBill];
    XCTAssertTrue([bazinga count] == 2, @"Aantal mensen op the shared Bill klopt niet.");
    MCPerson *thisPerson3 = [tonightsBill addPerson];
    [thisPerson3 setFirstName:@"Iva"];
    bazinga = [[MCWeAllPayStoreController defaultStore] getPeopleOnSharedBill:tonightsBill];
    XCTAssertTrue([bazinga count] == 3, @"Aantal mensen op the shared Bill klopt niet.");
    [MCSharedBill deleteSharedbill:tonightsBill];
}

- (void)testGetEmailaddressesFrom
{
    MCPerson *thisPerson = [MCPerson addPerson];
    [thisPerson setFirstName:@"Mark"];
    [thisPerson setLastName:@"Cornelisse"];
    NSString *emailAddressMark = @"info@markcornelisse.nl";
    [thisPerson addOneEmailAddressFromAString:emailAddressMark];
    MCEmailAddress *firstEmailAddressObject = [thisPerson getDefaultEmailAddressObject];
    NSString *emailAddress2Mark = @"mark.cornelisse@yahoo.com";
    [thisPerson addOneEmailAddressFromAString:emailAddress2Mark];
    [thisPerson addOneEmailAddressFromAString:emailAddress2Mark];
    NSString *emailAddress3Mark = @"m.p.cornelisse@gmail.com";
    [thisPerson addNewDefaultEmailAddressFromAString:emailAddress3Mark];
    [thisPerson setNewDefaultEmailaddressObject:firstEmailAddressObject];
    NSArray *theEmailAddressObjects = [[MCWeAllPayStoreController defaultStore] getEmailaddressesFrom:thisPerson];
    XCTAssertTrue([theEmailAddressObjects count] == 3, @"The wrong amount of objects is present.");
    [thisPerson deletAllEmailAddresses];
    [MCPerson deletePerson:thisPerson];
}

@end
