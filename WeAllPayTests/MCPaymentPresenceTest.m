//
//  MCPaymentPresentTest.m
//  We all pay
//
//  Created by Mark Cornelisse on 07-05-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCSharedBill+addons.h"
#import "MCPayment+addons.h"
#import "MCPerson+CoreDataProperties.h"
#import "MCEmailAddress+CoreDataProperties.h"
#import "MCPaymentPresence+CoreDataProperties.h"
#import "MCCurrency+addons.h"
#import "MCExchangeRate+CoreDataProperties.h"

#import "We_all_pay_Tests-Swift.h"

@interface MCPaymentPresenceTest : XCTestCase

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation MCPaymentPresenceTest

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

- (void)testAddAndDelete
{
    MCSharedBill *event = [MCSharedBill addSharedBillToContext:_context];
    MCEventModel *eventmodel = [[MCEventModel alloc] initWithEvent:event];
    [event setTripName:@"testAddAndDelete"];
    MCPerson *mark = [event addPerson];
    MCPersonModel *markModel = [[MCPersonModel alloc] initWithPerson:mark];
    [mark setFirstName:@"Mark"];
    [mark setLastName:@"Cornelisse"];
    [markModel addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    MCPerson *ilse = [event addPerson];
    MCPersonModel *ilseModel = [[MCPersonModel alloc] initWithPerson:ilse];
    [ilse setFirstName:@"Ilse"];
    [ilse setLastName:@"Béguin"];
    [ilseModel addOneEmailAddressFromAString:@"ilse.beguin@hotmail.com"];
    MCPerson *iva = [event addPerson];
    MCPersonModel *ivaModel = [[MCPersonModel alloc] initWithPerson:iva];
    [iva setFirstName:@"Iva"];
    [iva setLastName:@"Moslavac"];
    [ivaModel addOneEmailAddressFromAString:@"ivamavi2002@yahoo.co.uk"];
    
    MCPayment *firstPayment = [eventmodel addPayment];
    XCTAssertTrue([[firstPayment peopleSharingPayment] count] == [[event peoplePresent] count], @"Amount of people from the sharedBill is not correct.");
    NSSet *thesePeopleOnThisPayment = [firstPayment peopleSharingPayment];
    for (MCPaymentPresence *pp in thesePeopleOnThisPayment) {
        XCTAssertTrue([[pp isPersonPresent] boolValue], @"Person should be present on first creation of the payment.");
    }
    [event deletePayment:firstPayment];
    for (MCPaymentPresence *paymentPresence in thesePeopleOnThisPayment) {
        XCTAssertTrue([paymentPresence isDeleted], @"This person should be deleted.");
    }
    
    MCPayment *secondPayment = [eventmodel addPayment];
    [secondPayment setMoney:@8.90];
    [secondPayment setPayingPerson:iva];
    [secondPayment setDescriptionOfPayment:@"Ice cream"];
    NSSet *ppSecondPayment = [secondPayment peopleSharingPayment];
    [MCSharedBill deleteSharedbill:event];
    XCTAssertTrue([secondPayment isDeleted], @"The secondPayment should be deleted.");
    for (MCPayment *payment in [event payments]) {
        XCTAssertTrue([payment isDeleted], @"Payment should have been deleted.");
    }
    for (MCPaymentPresence *pp in ppSecondPayment) {
        XCTAssertTrue([pp isDeleted], @"People presence is not deleted on MCSharedbill delete.");
    }
    // Disconnect the eventModel from the event.
    [eventmodel reset];
}

- (void)testPeoplePresent
{
    MCSharedBill *event = [MCSharedBill addSharedBillToContext:_context];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event];
    MCPerson *mark = [event addPerson];
    MCPersonModel *markModel = [[MCPersonModel alloc] initWithPerson:mark];
    [markModel.person setFirstName:@"Mark"];
    [markModel.person setLastName:@"Cornelisse"];
    [markModel addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    MCPerson *ilse = [event addPerson];
    MCPersonModel *ilseModel = [[MCPersonModel alloc] initWithPerson:ilse];
    [ilseModel.person setFirstName:@"Ilse"];
    [ilseModel.person setLastName:@"Béguin"];
    [ilseModel addOneEmailAddressFromAString:@"ilse.beguin@hotmail.com"];
    MCPerson *iva = [event addPerson];
    MCPersonModel *ivaModel = [[MCPersonModel alloc] initWithPerson:iva];
    [ivaModel.person setFirstName:@"Iva"];
    [ivaModel.person setLastName:@"Moslavac"];
    [ivaModel addOneEmailAddressFromAString:@"ivamavi2002@yahoo.co.uk"];
    
    MCPayment *thisPayment = [eventModel addPayment];
    XCTAssertTrue([[thisPayment peoplePresentOnThisPayment] unsignedIntegerValue] == 3 , @"There should be three people present on this payment.");
    NSSet *thePeopleOfTheBill = [thisPayment peopleSharingPayment];
    MCPaymentPresence *pp = [thePeopleOfTheBill anyObject];
    [pp setIsPersonPresent:@NO];
    XCTAssertTrue([[thisPayment peoplePresentOnThisPayment] unsignedIntegerValue] == 2, @"Two out of three people should be present on this payment");
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testAveragePeopleShouldPay
{
    MCSharedBill *event = [MCSharedBill addSharedBillToContext:_context];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event];
    MCPerson *mark = [eventModel addPerson];
    MCPersonModel *markModel = [[MCPersonModel alloc] initWithPerson:mark];
    [markModel.person setFirstName:@"Mark"];
    [markModel.person setLastName:@"Cornelisse"];
    [markModel addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    MCPerson *ilse = [eventModel addPerson];
    MCPersonModel *ilseModel = [[MCPersonModel alloc] initWithPerson:ilse];
    [ilseModel.person setFirstName:@"Ilse"];
    [ilseModel.person setLastName:@"Béguin"];
    [ilseModel addOneEmailAddressFromAString:@"ilse.beguin@hotmail.com"];
    MCPerson *iva = [eventModel addPerson];
    MCPersonModel *ivaModel = [[MCPersonModel alloc] initWithPerson:iva];
    [ivaModel.person setFirstName:@"Iva"];
    [ivaModel.person setLastName:@"Moslavac"];
    [ivaModel addOneEmailAddressFromAString:@"ivamavi2002@yahoo.co.uk"];
    
    MCPayment *thisPayment = [eventModel addPayment];
    thisPayment.money = @9.00;
    [thisPayment recalculateAveragePeopleOweAndStore];
    double average = 9.00 / 3.00;
    
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
    MCPayment *thisPayment2 = [eventModel addPayment];
    thisPayment2.money = @60.00;
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
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testAmountShouldHavePaidBy
{
    MCSharedBill *event = [MCSharedBill addSharedBillToContext:_context];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event];
    MCPerson *mark = [eventModel addPerson];
    MCPersonModel *markModel = [[MCPersonModel alloc] initWithPerson:mark];
    [markModel.person setFirstName:@"Mark"];
    [markModel.person setLastName:@"Cornelisse"];
    [markModel addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    MCPerson *ilse = [eventModel addPerson];
    MCPersonModel *ilseModel = [[MCPersonModel alloc] initWithPerson:ilse];
    [ilseModel.person setFirstName:@"Ilse"];
    [ilseModel.person setLastName:@"Béguin"];
    [ilseModel addOneEmailAddressFromAString:@"ilse.beguin@hotmail.com"];
    MCPerson *iva = [eventModel addPerson];
    MCPersonModel *ivaModel = [[MCPersonModel alloc] initWithPerson:iva];
    [ivaModel.person setFirstName:@"Iva"];
    [ivaModel.person setLastName:@"Moslavac"];
    [ivaModel addOneEmailAddressFromAString:@"ivamavi2002@yahoo.co.uk"];
    
    MCPayment *thisPayment = [eventModel addPayment];
    [thisPayment setPayingPerson:mark];
    [thisPayment setDescriptionOfPayment:@"Drinken op een terras."];
    thisPayment.money = @9.00;
    [thisPayment recalculateAveragePeopleOweAndStore];
    
    MCPayment *thisPayment2 = [eventModel addPayment];
    [thisPayment2 setPayingPerson:iva];
    [thisPayment2 setDescriptionOfPayment:@"Food"];
    thisPayment2.money = @30.00;
    [thisPayment2 recalculateAveragePeopleOweAndStore];
    
    MCPayment *thisPayment3 = [eventModel addPayment];
    [thisPayment3 setPayingPerson:ilse];
    [thisPayment3 setDescriptionOfPayment:@"Movie"];
    thisPayment3.money = @36.00;
    [thisPayment3 recalculateAveragePeopleOweAndStore];
    
    // Does the sum function work correct when everybody is always present.
    NSNumber *sumOfAllOwesOnPaymentsForIlse = [event amountShouldHavePaidBy:ilse];
    XCTAssertEqualWithAccuracy([sumOfAllOwesOnPaymentsForIlse doubleValue], 25.00, 0.001, @"Sum of all PaymentsPresence is not equal.");
    
    // Does the sum function work correct when someone is not present on one payment.
    [thisPayment3 thisPerson:mark setIsPresent:@NO];
    NSNumber *sumOfAllOwesOnPaymentsForMark = [event amountShouldHavePaidBy:mark];
    XCTAssertEqualWithAccuracy([sumOfAllOwesOnPaymentsForMark doubleValue], 13.00, 0.001, @"Sum of all PaymentsPresence is not equal.");
    sumOfAllOwesOnPaymentsForIlse = [event amountShouldHavePaidBy:ilse];
    XCTAssertEqualWithAccuracy([sumOfAllOwesOnPaymentsForIlse doubleValue], 31.00, 0.001, @"Sum of all PaymentsPresence is not equal.");
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testSolveWhoOwesWhoWithPaymentPresence
{
    MCSharedBill *event = [MCSharedBill addSharedBillToContext:_context];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event];
    MCPerson *mark = [eventModel addPerson];
    MCPersonModel *markModel = [[MCPersonModel alloc] initWithPerson:mark];
    [markModel.person setFirstName:@"Mark"];
    [markModel.person setLastName:@"Cornelisse"];
    [markModel addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    MCPerson *ilse = [eventModel addPerson];
    MCPersonModel *ilseModel = [[MCPersonModel alloc] initWithPerson:ilse];
    [ilseModel.person setFirstName:@"Ilse"];
    [ilseModel.person setLastName:@"Béguin"];
    [ilseModel addOneEmailAddressFromAString:@"ilse.beguin@hotmail.com"];
    MCPerson *iva = [eventModel addPerson];
    MCPersonModel *ivaModel = [[MCPersonModel alloc] initWithPerson:iva];
    [ivaModel.person setFirstName:@"Iva"];
    [ivaModel.person setLastName:@"Moslavac"];
    [ivaModel addOneEmailAddressFromAString:@"ivamavi2002@yahoo.co.uk"];
    
    MCPayment *thisPayment = [eventModel addPayment];
    [thisPayment setPayingPerson:mark];
    [thisPayment setDescriptionOfPayment:@"Drinken op een terras."];
    thisPayment.money = @9.00;
    [thisPayment thisPerson:ilse setIsPresent:@NO];
    
    MCPayment *thisPayment2 = [eventModel addPayment];
    [thisPayment2 setPayingPerson:iva];
    [thisPayment2 setDescriptionOfPayment:@"Food"];
    thisPayment2.money = @30.00;
    
    MCPayment *thisPayment3 = [eventModel addPayment];
    [thisPayment3 setPayingPerson:ilse];
    [thisPayment3 setDescriptionOfPayment:@"Movie"];
    thisPayment3.money = @36.00;
    [thisPayment3 thisPerson:mark setIsPresent:@NO];
    
    NSArray *solution = [event solveWhoHasToPayWhoFromThisBill];
    XCTAssertTrue([solution count] == 2, @"The amount of objects in the solution is not ok.");
    XCTAssertEqualWithAccuracy([[[solution objectAtIndex:0] money] doubleValue], 5.50, 0.001, @"The amount Mark should pay is not 5.50.");
    XCTAssertEqualWithAccuracy([[[solution objectAtIndex:1] money] doubleValue], 2.50, 0.001, @"The amount Iva should pay is not 2.50.");
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testaddLateArrivalPaymentPresenceFor
{
    MCSharedBill *event = [MCSharedBill addSharedBillToContext:_context];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event];
    [event setTripName:@"Movie"];
    MCPerson *mark = [eventModel addPerson];
    MCPersonModel *markModel = [[MCPersonModel alloc] initWithPerson:mark];
    [markModel.person setFirstName:@"Mark"];
    [markModel.person setLastName:@"Cornelisse"];
    [markModel addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    MCPerson *ilse = [eventModel addPerson];
    MCPersonModel *ilseModel = [[MCPersonModel alloc] initWithPerson:ilse];
    [ilseModel.person setFirstName:@"Ilse"];
    [ilseModel.person setLastName:@"Béguin"];
    [ilseModel addOneEmailAddressFromAString:@"ilse.beguin@hotmail.com"];
    
    MCPayment *thisPayment = [eventModel addPayment];
    [thisPayment setPayingPerson:mark];
    [thisPayment setDescriptionOfPayment:@"Movie tickets"];
    [thisPayment setMoney:@26.70];
    [thisPayment setOnWhichBill:event];
    
    MCPerson *iva = [eventModel addPerson];
    MCPersonModel *ivaModel = [[MCPersonModel alloc] initWithPerson:iva];
    [ivaModel.person setFirstName:@"Iva"];
    [ivaModel.person setLastName:@"Moslavac"];
    [ivaModel addOneEmailAddressFromAString:@"ivamavi2002@yahoo.co.uk"];
    
    XCTAssertEqual([[thisPayment peopleSharingPayment] count], 3, @"There can only be 3 people sharing this payment.");
    MCPaymentPresence *presenceOfIva = [[iva sharingPayment] anyObject];
    XCTAssertFalse([[presenceOfIva isPersonPresent] boolValue], @"Iva should not be present.");
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testDeletePersonWithPresences
{
    MCSharedBill *event = [MCSharedBill addSharedBillToContext:_context];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event];
    MCPerson *mark = [eventModel addPerson];
    MCPersonModel *markModel = [[MCPersonModel alloc] initWithPerson:mark];
    [markModel.person setFirstName:@"Mark"];
    [markModel.person setLastName:@"Cornelisse"];
    [markModel addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    MCPerson *ilse = [eventModel addPerson];
    MCPersonModel *ilseModel = [[MCPersonModel alloc] initWithPerson:ilse];
    [ilseModel.person setFirstName:@"Ilse"];
    [ilseModel.person setLastName:@"Béguin"];
    [ilseModel addOneEmailAddressFromAString:@"ilse.beguin@hotmail.com"];
    MCPerson *iva = [eventModel addPerson];
    MCPersonModel *ivaModel = [[MCPersonModel alloc] initWithPerson:iva];
    [ivaModel.person setFirstName:@"Iva"];
    [ivaModel.person setLastName:@"Moslavac"];
    [ivaModel addOneEmailAddressFromAString:@"ivamavi2002@yahoo.co.uk"];
    
    MCPayment *thisPayment = [eventModel addPayment];
    [thisPayment setPayingPerson:mark];
    [thisPayment setDescriptionOfPayment:@"Drinken op een terras."];
    [thisPayment setMoney:@9.00];
    
    MCPayment *thisPayment2 = [eventModel addPayment];
    [thisPayment2 setPayingPerson:iva];
    [thisPayment2 setDescriptionOfPayment:@"Food"];
    [thisPayment2 setMoney:@30.00];
    
    MCPayment *thisPayment3 = [eventModel addPayment];
    [thisPayment3 setPayingPerson:ilse];
    [thisPayment3 setDescriptionOfPayment:@"Movie"];
    [thisPayment3 setMoney:@36.00];
    
    XCTAssertEqual([[iva sharingPayment] count], 3, @"There should be 3 paymentPresences for Iva.");
    NSSet *paymentPresencesIva= [iva sharingPayment];
    XCTAssertEqual([[thisPayment peopleSharingPayment] count], 3, @"There should be 3 paymentPresences on the first payment.");
    [event deletePerson:iva];
    XCTAssertEqual([[thisPayment peopleSharingPayment] count], 2, @"There should be 2 paymentPresences left on this payment.");
    XCTAssertTrue([iva isDeleted], @"Iva should be removed.");
    for (MCPaymentPresence *paymentPresence in paymentPresencesIva) {
        XCTAssertTrue([paymentPresence isDeleted], @"Payment presence of Iva should be deleted.");
    }
//    [thisBill amountShouldHavePaidBy:mark];
    XCTAssertEqualWithAccuracy([[event amountShouldHavePaidBy:mark] doubleValue], 37.5, 0.001, @"payment presence not updated after deletion.");
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testGetAverageOweFromPaymentInMainCurrency
{
    MCSharedBill *tonightsBill = [MCSharedBill addSharedBillToContext:_context];
    MCCurrency *mainCurrency = [MCCurrency generateCurrencyFromSelectedLocaleForContext:_context];
    [tonightsBill setMainCurrency:mainCurrency];
    MCPerson *marieke = [tonightsBill addPerson];
    [marieke setFirstName:@"Marieke"];
    [marieke setLastName:@"Siemensma"];
    MCPerson *merit = [tonightsBill addPerson];
    [merit setFirstName:@"Merit"];
    [merit setLastName:@"Koelink"];
    MCPayment *thisPayment = [tonightsBill addPayment];
    MCCurrency *paymentCurrency = [MCCurrency currencyFrom:@"USD" fromContext:_context];
    thisPayment.currency = paymentCurrency;
    [thisPayment setDescriptionOfPayment:@"Thee and cookies"];
    [thisPayment setPayingPerson:marieke];
    [thisPayment setMoney:@4.50];
    [thisPayment recalculateAveragePeopleOweAndStore];
    MCExchangeRate *exchangeRate = [[MCExchangeRate alloc] initWithContext:_context];
    exchangeRate.toCurrency = mainCurrency;
    exchangeRate.fromCurrency = paymentCurrency;
    exchangeRate.fromCurrency = paymentCurrency;
    [exchangeRate setExchangeRate:@0.72];
    exchangeRate.exchangeRate = @0.72;
    exchangeRate.payment = thisPayment;
    for (MCPaymentPresence *pp in [thisPayment peopleSharingPayment]) {
        XCTAssertEqualWithAccuracy(pp.averageOweFromPaymentInMainCurrency.doubleValue, [@(2.25 * 0.72) doubleValue], 0.001, @"Invalid value for getAverageOweFromPaymentInMainCurrency.");
    }
}

@end
