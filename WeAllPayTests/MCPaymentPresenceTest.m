//
//  MCPaymentPresentTest.m
//  We all pay
//
//  Created by Mark Cornelisse on 07-05-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCPayment+addons.h"
#import "MCPerson+addons.h"
#import "MCEmailAddress+addons.h"
#import "MCReturnPayment.h"
#import "MCPaymentPresence+addons.h"

@interface MCPaymentPresenceTest : XCTestCase
{
    MCWeAllPayStoreController *_mainController;
    NSManagedObjectContext *_context;
}
@end

@implementation MCPaymentPresenceTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _mainController = [MCWeAllPayStoreController defaultStore];
    _context = [[_mainController weAllPayStoreDocument] managedObjectContext];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddAndDelete
{
    MCSharedBill *thisBill = [MCSharedBill addSharedBill];
    MCPerson *mark = [thisBill addPerson];
    [mark setFirstName:@"Mark"];
    [mark setLastName:@"Cornelisse"];
    [mark addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    MCPerson *ilse = [thisBill addPerson];
    [ilse setFirstName:@"Ilse"];
    [ilse setLastName:@"Béguin"];
    [ilse addOneEmailAddressFromAString:@"ilse.beguin@hotmail.com"];
    MCPerson *iva = [thisBill addPerson];
    [iva setFirstName:@"Iva"];
    [iva setLastName:@"Moslavac"];
    [iva addOneEmailAddressFromAString:@"ivamavi2002@yahoo.co.uk"];
    
    MCPayment *thisPayment = [thisBill addPayment];
    XCTAssertTrue([[thisPayment peopleSharingPayment] count] == [[thisBill peoplePresent] count], @"Amount of people from the sharedBill is not correct.");
    NSSet *thesePeopleOnThisPayment = [thisPayment peopleSharingPayment];
    for (MCPaymentPresence *pp in thesePeopleOnThisPayment) {
        XCTAssertTrue([[pp isPersonPresent] boolValue], @"Person should be present on first creation of the payment.");
    }
    [thisBill deletePayment:thisPayment];
    for (MCPaymentPresence *pp in thesePeopleOnThisPayment) {
        XCTAssertTrue([pp isDeleted], @"This person should be deleted.");
    }
    
    MCPayment *secondPayment = [thisBill addPayment];
    NSSet *ppSecondPayment = [secondPayment peopleSharingPayment];
    [MCSharedBill deleteSharedbill:thisBill];
    XCTAssertTrue([secondPayment isDeleted], @"The secondPayment should be deleted.");
    for (MCPaymentPresence *pp in ppSecondPayment) {
        XCTAssertTrue([pp isDeleted], @"People presence is not deleted on MCSharedbill delete.");
    }
}

- (void)testPeoplePresent
{
    MCSharedBill *thisBill = [MCSharedBill addSharedBill];
    MCPerson *mark = [thisBill addPerson];
    [mark setFirstName:@"Mark"];
    [mark setLastName:@"Cornelisse"];
    [mark addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    MCPerson *ilse = [thisBill addPerson];
    [ilse setFirstName:@"Ilse"];
    [ilse setLastName:@"Béguin"];
    [ilse addOneEmailAddressFromAString:@"ilse.beguin@hotmail.com"];
    MCPerson *iva = [thisBill addPerson];
    [iva setFirstName:@"Iva"];
    [iva setLastName:@"Moslavac"];
    [iva addOneEmailAddressFromAString:@"ivamavi2002@yahoo.co.uk"];
    
    MCPayment *thisPayment = [thisBill addPayment];
    XCTAssertTrue([[thisPayment peoplePresentOnThisPayment] unsignedIntegerValue] == 3 , @"There should be three people present on this payment.");
    NSSet *thePeopleOfTheBill = [thisPayment peopleSharingPayment];
    MCPaymentPresence *pp = [thePeopleOfTheBill anyObject];
    [pp setIsPersonPresent:@NO];
    XCTAssertTrue([[thisPayment peoplePresentOnThisPayment] unsignedIntegerValue] == 2, @"Two out of three people should be present on this payment");
}

- (void)testAveragePeopleShouldPay
{
    MCSharedBill *thisBill = [MCSharedBill addSharedBill];
    MCPerson *mark = [thisBill addPerson];
    [mark setFirstName:@"Mark"];
    [mark setLastName:@"Cornelisse"];
    [mark addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    MCPerson *ilse = [thisBill addPerson];
    [ilse setFirstName:@"Ilse"];
    [ilse setLastName:@"Béguin"];
    [ilse addOneEmailAddressFromAString:@"ilse.beguin@hotmail.com"];
    MCPerson *iva = [thisBill addPerson];
    [iva setFirstName:@"Iva"];
    [iva setLastName:@"Moslavac"];
    [iva addOneEmailAddressFromAString:@"ivamavi2002@yahoo.co.uk"];
    
    MCPayment *thisPayment = [thisBill addPayment];
    [thisPayment putMoneyValueAsAString:@"9,00"];
    double average = 9.00 / 3.00;
    
    // Test [thisPayment averageAmountPeopleShouldHavePaidOnThisPayment]
    XCTAssertEqualWithAccuracy(average, [[thisPayment averageAmountPeopleShouldHavePaidOnThisPayment] doubleValue], 0.01, @"The average amount of money is different, from what I'm calculating.");
    for (MCPaymentPresence *pp in [thisPayment peopleSharingPayment]) {
        XCTAssertEqualWithAccuracy(average, [[pp averageOweFromPayment] doubleValue], 0.01, @"Average amount stored is not ok.");
    }
    
    // Test [thisPayment recalculateAveragePeopleOweAndStore]
    [[[thisPayment peopleSharingPayment] anyObject] setIsPersonPresent:@NO];
    [thisPayment recalculateAveragePeopleOweAndStore];
    for (MCPaymentPresence *pp in [thisPayment peopleSharingPayment]) {
        if ([[pp isPersonPresent] boolValue]) {
            XCTAssertEqualWithAccuracy(4.50, [[pp averageOweFromPayment] doubleValue], 0.01, @"Average amount stored is not ok.");
        } else {
            XCTAssertEqualWithAccuracy(0.00, [[pp averageOweFromPayment] doubleValue], 0.01, @"Average amount stored is not ok.");
        }
    }
    
    // Test [thisPayment fetchPaymentPresenceForPerson:]
    MCPayment *thisPayment2 = [thisBill addPayment];
    [thisPayment2 putMoneyValueAsAString:@"60,00"];
    [thisPayment2 setDescriptionOfPayment:@"Bier of some sort."];
    MCPaymentPresence *ppMarkOnThisPayment2 = [thisPayment2 fetchPaymentPresenceForPerson:mark];
    XCTAssertTrue([ppMarkOnThisPayment2 person] == mark && [ppMarkOnThisPayment2 payment] == thisPayment2, @"The paymentPresence fetched is the correct one.");
    
    // Test [thisPayment thisPerson: isPresent:]
    [thisPayment2 thisPerson:mark setIsPresent:@NO];
    XCTAssertFalse([[ppMarkOnThisPayment2 isPersonPresent] boolValue], @"Mark should not be present.");
    for (MCPaymentPresence *pp in [thisPayment2 peopleSharingPayment]) {
        if ([[pp isPersonPresent] boolValue]) {
            XCTAssertEqualWithAccuracy(60.00/2, [[pp averageOweFromPayment] doubleValue], 0.01, @"Average amount not updated on toggle.");
        } else {
            XCTAssertEqualWithAccuracy(0.00, [[pp averageOweFromPayment] doubleValue], 0.01, @"Average amount not resetted by now presence.");
        }
    }
    [thisPayment2 thisPerson:mark setIsPresent:@YES];
    XCTAssertTrue([[ppMarkOnThisPayment2 isPersonPresent] boolValue], @"Mark should not be present.");
    for (MCPaymentPresence *pp in [thisPayment2 peopleSharingPayment]) {
        if ([[pp isPersonPresent] boolValue]) {
            XCTAssertEqualWithAccuracy(60.00/3, [[pp averageOweFromPayment] doubleValue], 0.01, @"Average amount not updated on toggle.");
        } else {
            XCTAssertEqualWithAccuracy(0.00, [[pp averageOweFromPayment] doubleValue], 0.01, @"Average amount not resetted by now presence.");
        }
    }
}

- (void)testaAountShouldHavePaidBy
{
    MCSharedBill *thisBill = [MCSharedBill addSharedBill];
    MCPerson *mark = [thisBill addPerson];
    [mark setFirstName:@"Mark"];
    [mark setLastName:@"Cornelisse"];
    [mark addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    MCPerson *ilse = [thisBill addPerson];
    [ilse setFirstName:@"Ilse"];
    [ilse setLastName:@"Béguin"];
    [ilse addOneEmailAddressFromAString:@"ilse.beguin@hotmail.com"];
    MCPerson *iva = [thisBill addPerson];
    [iva setFirstName:@"Iva"];
    [iva setLastName:@"Moslavac"];
    [iva addOneEmailAddressFromAString:@"ivamavi2002@yahoo.co.uk"];
    
    MCPayment *thisPayment = [thisBill addPayment];
    [thisPayment putMoneyValueAsAString:@"9,00"];
    [thisPayment setPayingPerson:mark];
    [thisPayment setDescriptionOfPayment:@"Drinken op een terras."];
    // [thisPayment thisPerson:ilse setIsPresent:@NO];
    
    MCPayment *thisPayment2 = [thisBill addPayment];
    [thisPayment2 putMoneyValueAsAString:@"30,00"];
    [thisPayment2 setPayingPerson:iva];
    [thisPayment2 setDescriptionOfPayment:@"Food"];
    
    MCPayment *thisPayment3 = [thisBill addPayment];
    [thisPayment3 putMoneyValueAsAString:@"36.00"];
    [thisPayment3 setPayingPerson:ilse];
    [thisPayment3 setDescriptionOfPayment:@"Movie"];
    // [thisPayment3 thisPerson:mark setIsPresent:@NO];
    
    NSNumber *iets = [thisBill amountShouldHavePaidBy:ilse];
}

- (void)testIetsOfZo
{
    NSNumber *number1 = @20;
    NSNumber *number2 = @40;
    NSArray *numberArray = @[number1, number2];
    
    NSExpression *arrayExpression = [NSExpression expressionForConstantValue: numberArray];
    NSArray *argumentArray = @[arrayExpression];
    
    NSExpression* expression = [NSExpression expressionForFunction:@"sum:" arguments:argumentArray];
    id result = [expression expressionValueWithObject:nil context:nil];
    
    BOOL ok = [result isEqual: [NSNumber numberWithInt: 60]]; // ok == YES
}

@end
