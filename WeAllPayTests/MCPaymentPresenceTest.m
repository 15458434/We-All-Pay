//
//  MCPaymentPresentTest.m
//  We all pay
//
//  Created by Mark Cornelisse on 07-05-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCSharedBill+addons.h"
#import "MCPayment+CoreDataProperties.h"
#import "MCPerson+CoreDataProperties.h"
#import "MCEmailAddress+CoreDataProperties.h"
#import "MCPaymentPresence+CoreDataProperties.h"
#import "MCCurrency+CoreDataProperties.h"
#import "MCExchangeRate+CoreDataProperties.h"
#import "CurrencyConverter/CurrencyConverter.h"

#import "We_all_pay_Tests-Swift.h"

@interface MCPaymentPresenceTest : XCTestCase

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) MCEventsModel *eventsModel;

@end

@implementation MCPaymentPresenceTest

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

- (void)testAddAndDelete
{
    MCSharedBill *event = [_eventsModel addEvent];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventmodel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    [event setTripName:@"testAddAndDelete"];
    MCPerson *mark = [eventmodel addPerson];
    MCPersonModel *markModel = [[MCPersonModel alloc] initWithPerson:mark];
    [mark setFirstName:@"Mark"];
    [mark setLastName:@"Cornelisse"];
    [markModel addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    MCPerson *ilse = [eventmodel addPerson];
    MCPersonModel *ilseModel = [[MCPersonModel alloc] initWithPerson:ilse];
    [ilse setFirstName:@"Ilse"];
    [ilse setLastName:@"Béguin"];
    [ilseModel addOneEmailAddressFromAString:@"ilse.beguin@hotmail.com"];
    MCPerson *iva = [eventmodel addPerson];
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
    NSError *deleteError;
    [eventmodel deletePayment:firstPayment withError:&deleteError];
    XCTAssertNil(deleteError, @"There should be no error occuring when deleting this payment.");
    for (MCPaymentPresence *paymentPresence in thesePeopleOnThisPayment) {
        XCTAssertTrue([paymentPresence isDeleted], @"This person should be deleted.");
    }
    
    MCPayment *secondPayment = [eventmodel addPayment];
    [secondPayment setMoney:@8.90];
    [secondPayment setPayingPerson:iva];
    [secondPayment setDescriptionOfPayment:@"Ice cream"];
    NSSet *ppSecondPayment = [secondPayment peopleSharingPayment];
    [_eventsModel deleteWithEvent:event];
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
    MCSharedBill *event = [_eventsModel addEvent];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
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
    XCTAssertTrue(thisPayment.peoplePresentOnThisPayment == 3 , @"There should be three people present on this payment.");
    NSSet *thePeopleOfTheBill = [thisPayment peopleSharingPayment];
    MCPaymentPresence *pp = [thePeopleOfTheBill anyObject];
    [pp setIsPersonPresent:@NO];
    XCTAssertTrue(thisPayment.peoplePresentOnThisPayment == 2, @"Two out of three people should be present on this payment");
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testAveragePeopleShouldPay
{
    MCSharedBill *event = [_eventsModel addEvent];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
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
    MCPaymentModel *paymentModel = [[MCPaymentModel alloc] initWithPayment:thisPayment fromEventOfEventModel:eventModel];
    thisPayment.money = @9.00;
    [paymentModel recalculateAveragePeopleOweAndStore];
    double average = 9.00 / 3.00;
    
    XCTAssertEqualWithAccuracy(average, thisPayment.averageAmountPeopleShouldHavePaidOnThisPayment, 0.01, @"The average amount of money is different, from what I'm calculating.");
    for (MCPaymentPresence *pp in [thisPayment peopleSharingPayment]) {
        XCTAssertEqualWithAccuracy(average, [[pp averageOweFromPayment] doubleValue], 0.01, @"Average amount stored is not ok.");
    }
    
    // Test [thisPayment recalculateAveragePeopleOweAndStore]
    [[[thisPayment peopleSharingPayment] anyObject] setIsPersonPresent:@NO];
    [paymentModel recalculateAveragePeopleOweAndStore];
    for (MCPaymentPresence *pp in [thisPayment peopleSharingPayment]) {
        if ([[pp isPersonPresent] boolValue]) {
            XCTAssertEqualWithAccuracy(4.50, [[pp averageOweFromPayment] doubleValue], 0.01, @"Average amount stored is not ok.");
        } else {
            XCTAssertEqualWithAccuracy(0.00, [[pp averageOweFromPayment] doubleValue], 0.01, @"Average amount stored is not ok.");
        }
    }
    
    // Test [thisPayment fetchPaymentPresenceForPerson:]
    MCPayment *thisPayment2 = [eventModel addPayment];
    MCPaymentModel *payment2Model = [[MCPaymentModel alloc] initWithPayment:thisPayment2 fromEventOfEventModel:eventModel];
    thisPayment2.money = @60.00;
    [thisPayment2 setDescriptionOfPayment:@"Bier of some sort."];
    MCPaymentPresence *ppMarkOnThisPayment2 = [payment2Model paymentPresenceForPerson:mark withError:nil];
    XCTAssertTrue([ppMarkOnThisPayment2 person] == mark && [ppMarkOnThisPayment2 payment] == thisPayment2, @"The paymentPresence fetched is the correct one.");
    
    // Test [thisPayment thisPerson: isPresent:]
    [payment2Model updateWithPerson:mark to:NO error:nil];
    XCTAssertFalse([[ppMarkOnThisPayment2 isPersonPresent] boolValue], @"Mark should not be present.");
    for (MCPaymentPresence *pp in [thisPayment2 peopleSharingPayment]) {
        if ([[pp isPersonPresent] boolValue]) {
            XCTAssertEqualWithAccuracy(60.00/2, [[pp averageOweFromPayment] doubleValue], 0.01, @"Average amount not updated on toggle.");
        } else {
            XCTAssertEqualWithAccuracy(0.00, [[pp averageOweFromPayment] doubleValue], 0.01, @"Average amount not resetted by now presence.");
        }
    }
    [payment2Model updateWithPerson:mark to:YES error:nil];
    
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

- (void)testAmountShouldHavePaidBy {
    MCSharedBill *event = [_eventsModel addEvent];
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
    MCPaymentModel *paymentModel = [[MCPaymentModel alloc] initWithPayment:thisPayment fromEventOfEventModel:eventModel];
    [thisPayment setPayingPerson:mark];
    [thisPayment setDescriptionOfPayment:@"Drinken op een terras."];
    thisPayment.money = @9.00;
    [paymentModel recalculateAveragePeopleOweAndStore];
    
    MCPayment *thisPayment2 = [eventModel addPayment];
    MCPaymentModel *payment2Model = [[MCPaymentModel alloc] initWithPayment:thisPayment2 fromEventOfEventModel:eventModel];
    [thisPayment2 setPayingPerson:iva];
    [thisPayment2 setDescriptionOfPayment:@"Food"];
    thisPayment2.money = @30.00;
    [payment2Model recalculateAveragePeopleOweAndStore];
    
    MCPayment *thisPayment3 = [eventModel addPayment];
    MCPaymentModel *payment3Model = [[MCPaymentModel alloc] initWithPayment:thisPayment3 fromEventOfEventModel:eventModel];
    [thisPayment3 setPayingPerson:ilse];
    [thisPayment3 setDescriptionOfPayment:@"Movie"];
    thisPayment3.money = @36.00;
    [payment3Model recalculateAveragePeopleOweAndStore];
    
    // Does the sum function work correct when everybody is always present.
    MCSolutionModel *solutionModel = [[MCSolutionModel alloc] initWithEventModel:eventModel];
    NSError *error;
    NSNumber *sumOfAllOwesOnPaymentsForIlse = [solutionModel amountShouldHavePaidBy:ilse withError:&error];
    XCTAssertNil(error, @"No error should have been generated by amountShouldHavePaidBy:withError:");
    XCTAssertEqualWithAccuracy([sumOfAllOwesOnPaymentsForIlse doubleValue], 25.00, 0.001, @"Sum of all PaymentsPresence is not equal.");
    
    // Does the sum function work correct when someone is not present on one payment.
    [payment3Model updateWithPerson:mark to:NO error:nil];
    error = nil;
    NSNumber *sumOfAllOwesOnPaymentsForMark = [solutionModel amountShouldHavePaidBy:mark withError:&error];
    XCTAssertNil(error, @"No error should have been generated by amountShouldHavePaidBy:withError:");
    XCTAssertEqualWithAccuracy([sumOfAllOwesOnPaymentsForMark doubleValue], 13.00, 0.001, @"Sum of all PaymentsPresence is not equal.");
    error = nil;
    sumOfAllOwesOnPaymentsForIlse = [solutionModel amountShouldHavePaidBy:ilse withError:&error];
    XCTAssertNil(error, @"No error should have been generated by amountShouldHavePaidBy:withError:");
    XCTAssertEqualWithAccuracy([sumOfAllOwesOnPaymentsForIlse doubleValue], 31.00, 0.001, @"Sum of all PaymentsPresence is not equal.");
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testSolveWhoOwesWhoWithPaymentPresence {
    MCSharedBill *event = [_eventsModel addEvent];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event];
    MCSolutionModel *solutionModel = [[MCSolutionModel alloc] initWithEventModel:eventModel];
    MCPerson *mark = [eventModel addPerson];
    MCPersonModel *markModel = [[MCPersonModel alloc] initWithPerson:mark];
    [markModel.person setFirstName:@"Mark"];
    [markModel.person setLastName:@"Cornelisse"];
    [markModel addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    MCPerson *femke = [eventModel addPerson];
    MCPersonModel *femkeModel = [[MCPersonModel alloc] initWithPerson:femke];
    [femkeModel.person setFirstName:@"Femke"];
    [femkeModel.person setLastName:@"van Haaren"];
    [femkeModel addOneEmailAddressFromAString:@"femkevanhaaren@hotmail.com"];
    MCPerson *iva = [eventModel addPerson];
    MCPersonModel *ivaModel = [[MCPersonModel alloc] initWithPerson:iva];
    [ivaModel.person setFirstName:@"Iva"];
    [ivaModel.person setLastName:@"Moslavac"];
    [ivaModel addOneEmailAddressFromAString:@"ivamavi2002@yahoo.co.uk"];
    
    MCPayment *thisPayment = [eventModel addPayment];
    MCPaymentModel *paymentModel = [[MCPaymentModel alloc] initWithPayment:thisPayment fromEventOfEventModel:eventModel];
    [thisPayment setPayingPerson:mark];
    [thisPayment setDescriptionOfPayment:@"Drinken op een terras."];
    thisPayment.money = @9.00;
    [paymentModel updateWithPerson:femke to:NO error:nil];
    
    MCPayment *thisPayment2 = [eventModel addPayment];
    [thisPayment2 setPayingPerson:iva];
    [thisPayment2 setDescriptionOfPayment:@"Food"];
    thisPayment2.money = @30.00;
    
    MCPayment *thisPayment3 = [eventModel addPayment];
    MCPaymentModel *payment3Model = [[MCPaymentModel alloc] initWithPayment:thisPayment3 fromEventOfEventModel:eventModel];
    [thisPayment3 setPayingPerson:femke];
    [thisPayment3 setDescriptionOfPayment:@"Movie"];
    thisPayment3.money = @36.00;
    [payment3Model updateWithPerson:mark to:NO error:nil];
    
    NSError *solveError;
    NSArray<MCReturnPayment *> *solution = [solutionModel originalSolveWhoHasToPayWhoFromThisBillWithError:&solveError];
    XCTAssertNil(solveError);
    NSLog(@"solution: %@", solution);
    XCTAssertTrue([solution count] == 2, @"The amount of objects in the solution is not ok.");
    MCReturnPayment *firstReturnPayment = solution[0];
    XCTAssertEqualWithAccuracy(firstReturnPayment.money.doubleValue, 5.50, 0.001, @"The amount Mark should pay is not 5.50.");
    MCReturnPayment *secondReturnPayment = solution[1];
    XCTAssertEqualWithAccuracy(secondReturnPayment.money.doubleValue, 2.50, 0.001, @"The amount Iva should pay is not 2.50.");
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testaddLateArrivalPaymentPresenceFor
{
    MCSharedBill *event = [_eventsModel addEvent];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
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
    MCSharedBill *event = [_eventsModel addEvent];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
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
    [eventModel deletePerson:iva];
    XCTAssertEqual([[thisPayment peopleSharingPayment] count], 2, @"There should be 2 paymentPresences left on this payment.");
    XCTAssertTrue([iva isDeleted], @"Iva should be removed.");
    for (MCPaymentPresence *paymentPresence in paymentPresencesIva) {
        XCTAssertTrue([paymentPresence isDeleted], @"Payment presence of Iva should be deleted.");
    }
    MCSolutionModel *solutionModel = [[MCSolutionModel alloc] initWithEventModel:eventModel];
    NSError *error;
    XCTAssertEqualWithAccuracy([solutionModel amountShouldHavePaidBy:mark withError:&error].doubleValue, 37.5, 0.001, @"payment presence not updated after deletion.");
    XCTAssertNil(error, @"No error should have been generated by amountShouldHavePaidBy:withError:");
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testGetAverageOweFromPaymentInMainCurrency
{
    MCSharedBill *event = [_eventsModel addEvent];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    NSError *error;
    MCCurrency *mainCurrency = [currencyModel generateCurrencyFromSelectedLocaleWithError:&error];
    XCTAssertNil(error, @"No error should been have generated.");
    [event setMainCurrency:mainCurrency];
    MCPerson *marieke = [eventModel addPerson];
    [marieke setFirstName:@"Marieke"];
    [marieke setLastName:@"Siemensma"];
    MCPerson *merit = [eventModel addPerson];
    [merit setFirstName:@"Merit"];
    [merit setLastName:@"Koelink"];
    MCPayment *thisPayment = [eventModel addPayment];
    MCPaymentModel *paymentModel = [[MCPaymentModel alloc] initWithPayment:thisPayment fromEventOfEventModel:eventModel];
    MCCurrency *paymentCurrency = [currencyModel currencyFromCurrencyCode:@"USD"];
    thisPayment.currency = paymentCurrency;
    [thisPayment setDescriptionOfPayment:@"Thee and cookies"];
    [thisPayment setPayingPerson:marieke];
    [thisPayment setMoney:@4.50];
    [paymentModel recalculateAveragePeopleOweAndStore];
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
