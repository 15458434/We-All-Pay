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

@interface MCPaymentAddonsTest : XCTestCase
{
    MCWeAllPayStoreController *mainController;
    NSManagedObjectContext *context;
}

@end

@implementation MCPaymentAddonsTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    mainController = [MCWeAllPayStoreController defaultStore];
    context = [[mainController weAllPayStoreDocument] managedObjectContext];
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
    XCTAssertTrue([MCPayment isTableInDatabaseEmpty], @"MCPayment table is not empty");
    
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

@end
