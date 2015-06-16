//
//  MCPaymentAddonsTest.m
//  We all pay
//
//  Created by Mark Cornelisse on 08-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCPayment+addons.h"
#import "MCPerson+addons.h"
#import "MCEmailAddress+addons.h"
#import "MCReturnPayment.h"
#import "MCCurrency+addons.h"
#import "MCExchangeRate+addons.h"

#import "XRCurrencyStoreController.h"

@interface MCPaymentAddonsTest : XCTestCase

@property (nonatomic, strong) MCWeAllPayStoreController *mainController;
@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation MCPaymentAddonsTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSError *error;
    NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error];
    XCTAssertTrue(persistentStore, @"Something went wrong opening the In Memory Store: %@", [error localizedDescription]);
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_context setPersistentStoreCoordinator:persistentStoreCoordinator];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMCPaymentAddons
{
    MCPerson *thisPerson = [MCPerson addPerson];
    [thisPerson setFirstName:@"Mark"];
    [thisPerson setLastName:@"Cornelisse"];
    [thisPerson addNewDefaultEmailAddressFromAString:@"support@markcornelisse.nl"];
    MCPayment *thisPayment = [MCPayment addPayment];
    [thisPayment setDescriptionOfPayment:@"Beer"];
    [thisPayment setMoney:@3.25];
    XCTAssertFalse([thisPayment hasPayer], @"PayerPresent");
    [thisPayment setPayingPerson:thisPerson];
    XCTAssertTrue([thisPayment hasPayer], @"No payer present on thisPayment");
    
    [MCPayment deletePayment:thisPayment];
    XCTAssertTrue([thisPayment isDeleted], @"MCPayment table is not empty");
    
    [MCPerson deletePerson:thisPerson];
}

- (void)testMoneyValuePutAndGet
{
    // This test tests the functionality of putting and getting moneyValues in MCPayment+addons by passing along strings.
    MCSharedBill *tonightsBill = [MCSharedBill addSharedBill];
    MCPerson *thisPerson = [tonightsBill addPerson];
    [thisPerson setFirstName:@"Mark"];
    [thisPerson setLastName:@"Cornelisse"];
    [thisPerson addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    MCPayment *thisPayment = [tonightsBill addPayment];
    [thisPayment setPayingPerson:thisPerson];
    [thisPayment setDescriptionOfPayment:@"Bazinga"];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setLocale:[NSLocale currentLocale]];
    [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *verifyNumber = @(9.87);
    NSString *verifyNumberString = [nf stringFromNumber:verifyNumber];
    [thisPayment putMoneyValueAsAString:verifyNumberString];
    XCTAssertEqualWithAccuracy([verifyNumber doubleValue], [[thisPayment money] doubleValue], 0.005, @"thisPayment value not the same as the original.");
    XCTAssert([verifyNumberString isEqualToString:[thisPayment getMoneyValueAsAString]], @"thisPayment money string not equal to the string the way it should be.");
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *verifyCurrencyString = [nf stringFromNumber:verifyNumber];
    [thisPayment putMoneyValueInCurrencyAsAString:verifyCurrencyString];
    XCTAssertEqualWithAccuracy([verifyNumber doubleValue], [[thisPayment money] doubleValue], 0.005, @"thisPayment value no the same as the original currency");
    XCTAssert([verifyCurrencyString isEqualToString:[thisPayment getMoneyValueInCurrencyAsAString]], @"thisPayment currency string not equal to the string the way it should be");
    [MCSharedBill deleteSharedbill:tonightsBill];
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

- testAddPaymentForExchangeRateCreation
{
    MCPayment *thisPayment = [MCPayment addPaymentInContext:_context];
    XCTAssertNotNil([thisPayment exchangeRate], @"There should be an exchangeRate in this payment.");
    XCTAssertEqualWithAccuracy([[[thisPayment exchangeRate] exchangeRate] doubleValue], 1.000, 0.0001, @"Value of exchangeRate should be 1.");
    XCTAssert([[[thisPayment exchangeRate] status] shortValue] == valid, @"exchangeRate status should be valid");
}

@end
