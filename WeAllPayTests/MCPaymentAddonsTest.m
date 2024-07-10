//
//  MCPaymentAddonsTest.m
//  We all pay
//
//  Created by Mark Cornelisse on 08-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCSharedBill+addons.h"
#import "MCPayment+addons.h"
#import "MCPerson+addons.h"
#import "MCEmailAddress+CoreDataProperties.h"
#import "MCCurrency+addons.h"
#import "MCExchangeRate+addons.h"

#import "We_all_pay_Tests-Swift.h"

@interface MCPaymentAddonsTest : XCTestCase

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation MCPaymentAddonsTest

- (void)setUp {
    [super setUp];
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSError *error;
    NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error];
    XCTAssertTrue(persistentStore, @"Something went wrong opening the In Memory Store: %@", [error localizedDescription]);
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _context.persistentStoreCoordinator = persistentStoreCoordinator;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMCPaymentAddons
{
    MCPerson *thisPerson = [[MCPerson alloc] initWithContext:_context];
    [thisPerson setFirstName:@"Mark"];
    [thisPerson setLastName:@"Cornelisse"];
    [thisPerson addNewDefaultEmailAddressFromAString:@"support@markcornelisse.nl"];
    MCPayment *thisPayment = [[MCPayment alloc] initWithContext:_context];
    [thisPayment setDescriptionOfPayment:@"Beer"];
    [thisPayment setMoney:@3.25];
    XCTAssertFalse([thisPayment hasPayer], @"PayerPresent");
    [thisPayment setPayingPerson:thisPerson];
    XCTAssertTrue([thisPayment hasPayer], @"No payer present on thisPayment");
    
    [MCPayment deletePayment:thisPayment];
    XCTAssertTrue([thisPayment isDeleted], @"MCPayment table is not empty");
    
    [MCPerson deletePerson:thisPerson];
}

- (void)testCurrency
{
    // This test checks to see if currency is being setup when a new payment is being made.
    MCPayment *thisPayment = [MCPayment addPaymentInContext:_context];
    NSString *currentCurrencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
    XCTAssertTrue([[[thisPayment currency] code] isEqualToString:currentCurrencyCode], @"%@ should be the same as %@", [[thisPayment currency] code], currentCurrencyCode);
}

- (void)testMoneyInMainCurrency
{
    // This test checks to see if currency is correctly converted to the mainCurrency of the sharedBill.
    MCSharedBill *tonightsBill = [MCSharedBill addSharedBillToContext:_context];
    tonightsBill.mainCurrency = [MCCurrency currencyFrom:@"EUR" fromContext:_context];
    MCPayment *thisPayment = [tonightsBill addPayment];
    thisPayment.currency = [MCCurrency currencyFrom:@"USD" fromContext:_context];
    MCExchangeRate *exchangeRate = [thisPayment addExchangeRate];
    [exchangeRate setExchangeRate:@0.7424];
    [thisPayment setMoney:@2.97];
    NSNumber *valueInMainCurrency = [thisPayment moneyInMainCurrency];
    XCTAssertEqualWithAccuracy([valueInMainCurrency doubleValue], [@(0.7424) doubleValue] * [@(2.97) doubleValue], 0.001, @"Main value after conversion not ok. %@ = %@", valueInMainCurrency, @((double)0.7424 * (double)2.97));
}

- (void)testAddPaymentForExchangeRateCreation
{
    MCPayment *thisPayment = [MCPayment addPaymentInContext:_context];
    XCTAssertNotNil([thisPayment exchangeRate], @"There should be an exchangeRate in this payment.");
    XCTAssertEqualWithAccuracy([[[thisPayment exchangeRate] exchangeRate] doubleValue], 1.000, 0.0001, @"Value of exchangeRate should be 1.");
    XCTAssert([[[thisPayment exchangeRate] status] shortValue] == MCExchangeRateStatusValid, @"exchangeRate status should be valid");
}

@end
