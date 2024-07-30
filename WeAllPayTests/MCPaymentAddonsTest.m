//
//  MCPaymentAddonsTest.m
//  We all pay
//
//  Created by Mark Cornelisse on 08-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CurrencyConverter/CurrencyConverter.h"

#import "MCSharedBill+addons.h"
#import "MCPayment+CoreDataProperties.h"
#import "MCPerson+CoreDataProperties.h"
#import "MCEmailAddress+CoreDataProperties.h"
#import "MCCurrency+CoreDataProperties.h"
#import "MCExchangeRate+CoreDataProperties.h"

#import "We_all_pay_Tests-Swift.h"

@interface MCPaymentAddonsTest : XCTestCase

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) MCEventsModel *eventsModel;

@end

@implementation MCPaymentAddonsTest

- (void)setUp {
    [super setUp];
    [WeAllPayStoreController.defaultStore openStoreOfType:NSInMemoryStoreType];
    _context = WeAllPayStoreController.defaultStore.viewContext;
    _eventsModel = [[MCEventsModel alloc] initWithManagedObjectContext:_context andFetchedResultsControllerdDelegate:nil];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMCPaymentAddons
{
    MCSharedBill *event = [_eventsModel addEvent];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    MCPerson *thisPerson = [eventModel addPerson];
    [thisPerson setFirstName:@"Mark"];
    [thisPerson setLastName:@"Cornelisse"];
    MCPersonModel *model = [[MCPersonModel alloc] initWithPerson:thisPerson];
    [model addNewDefaultEmailAddressFromAString:@"support@markcornelisse.nl"];
    MCPayment *thisPayment = [eventModel addPayment];
    [thisPayment setDescriptionOfPayment:@"Beer"];
    [thisPayment setMoney:@3.25];
    XCTAssertFalse([thisPayment hasPayer], @"PayerPresent");
    [thisPayment setPayingPerson:thisPerson];
    XCTAssertTrue([thisPayment hasPayer], @"No payer present on thisPayment");
    
    NSError *deleteError;
    [eventModel deletePayment:thisPayment withError:&deleteError];
    XCTAssertNil(deleteError, @"No error should happening when payment is deleted");
    XCTAssertTrue([thisPayment isDeleted], @"MCPayment table is not empty");
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testCurrency
{
    MCSharedBill *event = [_eventsModel addEvent];
    MCCurrencyModel *currenceModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currenceModel];
    // This test checks to see if currency is being setup when a new payment is being made.
    MCPayment *thisPayment = [eventModel addPayment];
    NSString *currentCurrencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
    XCTAssertTrue([[[thisPayment currency] code] isEqualToString:currentCurrencyCode], @"%@ should be the same as %@", [[thisPayment currency] code], currentCurrencyCode);
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testMoneyInMainCurrency
{
    // This test checks to see if currency is correctly converted to the mainCurrency of the sharedBill.
    MCSharedBill *event = [_eventsModel addEvent];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    event.mainCurrency = [currencyModel currencyFromCurrencyCode:@"EUR"];
    MCPayment *thisPayment = [eventModel addPayment];
    thisPayment.currency = [currencyModel currencyFromCurrencyCode:@"USD"];
    MCExchangeRate *exchangeRate = [eventModel addExchangeRateForPayment:thisPayment];
    exchangeRate.exchangeRate = @0.7424;
    thisPayment.money = @2.97;
    NSNumber *valueInMainCurrency = [thisPayment moneyInMainCurrency];
    XCTAssertEqualWithAccuracy([valueInMainCurrency doubleValue], [@(0.7424) doubleValue] * [@(2.97) doubleValue], 0.001, @"Main value after conversion not ok. %@ = %@", valueInMainCurrency, @((double)0.7424 * (double)2.97));
}

- (void)testAddPaymentForExchangeRateCreation {
    MCSharedBill *event = [_eventsModel addEvent];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    MCPayment *thisPayment = [eventModel addPayment];
    XCTAssertNotNil([thisPayment exchangeRate], @"There should be an exchangeRate in this payment.");
    XCTAssertEqualWithAccuracy([[[thisPayment exchangeRate] exchangeRate] doubleValue], 1.000, 0.0001, @"Value of exchangeRate should be 1.");
    XCTAssert([[[thisPayment exchangeRate] status] shortValue] == MCExchangeRateStatusValid, @"exchangeRate status should be valid");
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

@end
