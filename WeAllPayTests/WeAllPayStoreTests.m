//
//  WeAllPayTests.m
//  WeAllPayTests
//
//  Created by Mark Cornelisse on 21-03-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CurrencyConverter/CurrencyConverter.h"

#import "MCPerson+CoreDataProperties.h"
#import "MCPayment+CoreDataProperties.h"
#import "MCSharedBill+addons.h"
#import "MCEmailAddress+CoreDataProperties.h"

#import "We_all_pay_Tests-Swift.h"

@interface WeAllPayStoreTests : XCTestCase

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation WeAllPayStoreTests

- (void)setUp {
    [super setUp];
    [WeAllPayStoreController.defaultStore openStoreOfType:NSInMemoryStoreType];
    _context = WeAllPayStoreController.defaultStore.viewContext;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMCPersonAddonsGetName
{
    MCPerson *thisPerson = [[MCPerson alloc] initWithContext:_context];
    MCPersonModel *model = [[MCPersonModel alloc] initWithPerson:thisPerson];
    [model.person setFirstName:@"Connie"];
    [model.person setLastName:@"Carter"];
    [model addOneEmailAddressFromAString:@"connie@markcornelisse.nl"];
    XCTAssertTrue([thisPerson.name isEqualToString:@"Connie"], @"First name is not selected when it's available.");
    XCTAssertTrue([thisPerson.fullName isEqualToString:@"Connie Carter"]);
    MCPerson *thisPersonWithMissingFirstName = [[MCPerson alloc] initWithContext:_context];
    MCPersonModel *modelWithMissingFirstName = [[MCPersonModel alloc] initWithPerson:thisPersonWithMissingFirstName];
    [modelWithMissingFirstName.person setLastName:@"Carter"];
    [modelWithMissingFirstName addOneEmailAddressFromAString:@"connie@markcornelisse.nl"];
    XCTAssertTrue([thisPersonWithMissingFirstName.name isEqualToString:@"Carter"], @"Last is not selected when first name is not available");
    XCTAssertTrue([thisPersonWithMissingFirstName.fullName isEqualToString:@"Carter"], @"Fullname is wrong when first name is missing.");
    MCPerson *thisPersonWithMissingFirstAndLastName = [[MCPerson alloc] initWithContext:_context];
    MCPersonModel *modelWithMissingFirstAndLastName = [[MCPersonModel alloc] initWithPerson:thisPersonWithMissingFirstAndLastName];
    [modelWithMissingFirstAndLastName addOneEmailAddressFromAString:@"connie@markcornelisse.nl"];
    XCTAssertTrue([thisPersonWithMissingFirstAndLastName.name isEqualToString:@"connie@markcornelisse.nl"], @"emailAddress is not selected when both first and lastname are not selected.");
    XCTAssertTrue([thisPersonWithMissingFirstAndLastName.fullName isEqualToString:@"connie@markcornelisse.nl"], @"emailAddress is not selected when both first and lastnames are not selected.");
}

- (void)testPersonExistenceOnSharedBill
{
    MCSharedBill *event = [[MCSharedBill alloc] initWithContext:_context];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    MCPerson *mark = [eventModel addPerson];
    MCPersonModel *markModel = [[MCPersonModel alloc] initWithPerson:mark];
    [markModel.person setFirstName:@"Mark"];
    [markModel.person setLastName:@"Cornelisse"];
    [markModel addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    [markModel addOneEmailAddressFromAString:@"support@markcornelisse.nl"];
    [markModel addNewDefaultEmailAddressFromAString:@"m.p.cornelisse@gmail.com"];
    XCTAssertEqualObjects(@"m.p.cornelisse@gmail.com", [mark defaultEmailAddress], @"Default emailAddress is not right.");
    NSString *markFirstName = @"Mark";
    NSString *markLastName = @"Cornelisse";
    NSString *markDefaultEmailAddress = @"m.p.cornelisse@gmail.com";
    XCTAssertTrue([event isPresentWithFirstName:markFirstName andLastName:markLastName andEmailAddress:markDefaultEmailAddress], @"Person is not present.");
    NSString *ilseFirstName = @"Ilse";
    NSString *ilseLastName = @"Béguin";
    NSString *ilseDefaultEmailAddress = @"ilse.beguin@hotmail.com";
    XCTAssertFalse([event isPresentWithFirstName:ilseFirstName andLastName:ilseLastName andEmailAddress:ilseDefaultEmailAddress], @"Person is present.");
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}


- (void)testGetPeopleOnSharedBill
{
    MCSharedBill *event = [[MCSharedBill alloc] initWithContext:_context];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    NSArray *peoplePresentOnEvent = eventModel.peoplePresentOnEvent;
    XCTAssertTrue([peoplePresentOnEvent count] == 0, @"Aantal mensen op the shared Bill klopt niet.");
    MCPerson *thisPerson = [eventModel addPerson];
    [thisPerson setFirstName:@"Mark"];
    peoplePresentOnEvent = eventModel.peoplePresentOnEvent;
    XCTAssertTrue([peoplePresentOnEvent count] == 1, @"Aantal mensen op the shared Bill klopt niet.");
    MCPerson *thisPerson2 = [eventModel addPerson];
    [thisPerson2 setFirstName:@"Ilse"];
    peoplePresentOnEvent = eventModel.peoplePresentOnEvent;
    XCTAssertTrue([peoplePresentOnEvent count] == 2, @"Aantal mensen op the shared Bill klopt niet.");
    MCPerson *thisPerson3 = [eventModel addPerson];
    [thisPerson3 setFirstName:@"Iva"];
    peoplePresentOnEvent = eventModel.peoplePresentOnEvent;
    XCTAssertTrue([peoplePresentOnEvent count] == 3, @"Aantal mensen op the shared Bill klopt niet.");
    [MCSharedBill deleteSharedbill:event];
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testGetEmailaddressesFrom
{
    MCPerson *thisPerson = [[MCPerson alloc] initWithContext:_context];
    MCPersonModel *personModel = [[MCPersonModel alloc] initWithPerson:thisPerson];
    [personModel.person setFirstName:@"Mark"];
    [personModel.person setLastName:@"Cornelisse"];
    NSString *emailAddressMark = @"info@markcornelisse.nl";
    [personModel addOneEmailAddressFromAString:emailAddressMark];
    MCEmailAddress *firstEmailAddressObject = thisPerson.defaultEmailAddressObject;
    NSString *emailAddress2Mark = @"mark.cornelisse@yahoo.com";
    [personModel addOneEmailAddressFromAString:emailAddress2Mark];
    [personModel addOneEmailAddressFromAString:emailAddress2Mark];
    NSString *emailAddress3Mark = @"m.p.cornelisse@gmail.com";
    [personModel addNewDefaultEmailAddressFromAString:emailAddress3Mark];
    [personModel updateDefaultEmailAddressObject:firstEmailAddressObject];
    [personModel prepareForUseWithPerson:thisPerson];
    NSArray *theEmailAddressObjects = personModel.emailaddresses;
    XCTAssertTrue([theEmailAddressObjects count] == 3, @"The wrong amount of objects is present.");
    [personModel deleteAllEmailAddresses];
    [_context deleteObject:personModel.person];
}

@end
