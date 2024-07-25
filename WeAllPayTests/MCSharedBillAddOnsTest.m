//
//  MCSharedBillAddOnsTest.m
//  We all pay
//
//  Created by Mark Cornelisse on 08-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import XCTest;
#import "CurrencyConverter/CurrencyConverter.h"

#import "MCSharedBill+addons.h"
#import "MCPerson+CoreDataProperties.h"
#import "MCEmailAddress+CoreDataProperties.h"
#import "MCPayment+CoreDataProperties.h"
#import "MCPaymentPresence+CoreDataProperties.h"
#import "MCCurrency+CoreDataProperties.h"
#import "MCExchangeRate+CoreDataProperties.h"

#import "We_all_pay_Tests-Swift.h"

@interface MCSharedBillAddOnsTest : XCTestCase

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation MCSharedBillAddOnsTest

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

- (void)testMCSharedBillAddOns1
{
//    XCTAssertTrue([MCSharedBill isTableInDatabaseEmpty], @"There is a sharedBill present in the empty table?");
    MCSharedBill *event = [[MCSharedBill alloc] initWithContext:_context];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    [event setTripName:@"Movie"];
    XCTAssertFalse([event areTherePeople], @"There are people on a new event?");
    MCPerson *markmovie = [eventModel addPerson];
    MCPersonModel *markModel = [[MCPersonModel alloc] initWithPerson:markmovie];
    [markModel.person setFirstName:@"Mark"];
    [markModel.person setLastName:@"Cornelisse"];
    [markModel addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    [markModel addOneEmailAddressFromAString:@"support@markcornelisse.nl"];
    MCPerson *ilsemovie = [eventModel addPerson];
    MCPersonModel *ilseModel = [[MCPersonModel alloc] initWithPerson:ilsemovie];
    [ilseModel.person setFirstName:@"Ilse"];
    [ilseModel.person setLastName:@"Béguin"];
    [ilseModel addOneEmailAddressFromAString:@"ilse@markcornelisse.nl"];
    MCPerson *conniemovie = [eventModel addPerson];
    MCPersonModel *connieModel = [[MCPersonModel alloc] initWithPerson:conniemovie];
    [connieModel.person setFirstName:@"Connie"];
    [connieModel.person setLastName:@"Carter"];
    [connieModel addOneEmailAddressFromAString:@"connie@markcornelisse.nl"];
    MCPerson *liekemovie = [eventModel addPerson];
    MCPersonModel *liekeModel = [[MCPersonModel alloc] initWithPerson:liekemovie];
    [liekeModel.person setFirstName:@"Lieke"];
    [liekeModel.person setLastName:@"Koopman"];
    [liekeModel addOneEmailAddressFromAString:@"lieke@markcornelisse.nl"];
    [liekeModel addNewDefaultEmailAddressFromAString:@"liekeNewDefault@markcornelisse.nl"];
    MCPayment *tickets = [eventModel addPayment];
    [tickets setPayingPerson:markmovie];
    [tickets setMoney:@(8.90*4)];
    [tickets setDescriptionOfPayment:@"Tickets"];
    MCPayment *drinksAndPopcorn = [eventModel addPayment];
    [drinksAndPopcorn setPayingPerson:liekemovie];
    [drinksAndPopcorn setMoney:@34.40];
    [drinksAndPopcorn setDescriptionOfPayment:@"Drinks and popcorn for the movie."];
    MCPayment *parking = [eventModel addPayment];
    [parking setPayingPerson:liekemovie];
    [parking setMoney:@6.00];
    [parking setDescriptionOfPayment:@"Parking"];
    XCTAssertTrue([event areTherePeople], @"There are no people when 4 people should have been added?");
    XCTAssertTrue([event totalAmountOfPeoplePresent] == 4, @"4 people were added, but the returned amount it not 4?");
    XCTAssertTrue([event totalAmountOfPeopleWhoHavePaid] == 2, @"Total amount of people who have paid is not 3");
    XCTAssertTrue([liekemovie.totalSumPaid doubleValue] == 40.40, @"Total sum is wrong when adding multiple payments.");
    XCTAssertTrue([[event totalSumOfMoneyOfThisSharedBill] doubleValue] == 8.90*4+34.40+6.00, @"Total sum is wrong when adding multiple payments.");
    XCTAssertTrue([event hasPersonPaidSomething:liekemovie], @"This person should have paid something.");
    XCTAssertTrue([event hasPersonPaidSomething:markmovie], @"This person should have paid something.");
    XCTAssertFalse([event hasPersonPaidSomething:ilsemovie], @"This person shouldn't have paid something.");
    XCTAssertFalse([event hasPersonPaidSomething:conniemovie], @"This person shouldn't have paid something.");
    XCTAssertTrue([event doesEveryoneHaveAnEmailAddress], @"Everyone should have an email address");
    XCTAssertTrue([[event amountPeopleShouldHavePaid] doubleValue] == (8.90*4+34.40+6.00)/4, @"The average calculated amount is wrong.");
    NSArray<MCReturnPayment *> *solution = [event solveWhoHasToPayWhoFromThisBill];
    XCTAssertEqual([solution count], 3, @"Amount of MCReturnPayment on solved bill is not ok.");
    MCReturnPayment *one = solution[0];
    XCTAssertEqual(ilsemovie, [one payer], @"Payer not equal to the person that should pay.");
    XCTAssertEqualWithAccuracy([@16.6 doubleValue], [[one money] doubleValue], 0.001, @"Amount of money not equal to what should be paid.");
    XCTAssertEqual(markmovie, [one receiver], @"Receiver not equal to the person that should receive.");
    MCReturnPayment *two = solution[1];
    XCTAssertEqual(ilsemovie, [two payer], @"Payer not equal to the person that should pay.");
    XCTAssertEqualWithAccuracy([@2.4 doubleValue], [[two money] doubleValue], 0.001, @"Amount of money not equal to what should be paid.");
    XCTAssertEqual(liekemovie, [two receiver], @"Receiver not equal to the person that should receive.");
    MCReturnPayment *three = solution[2];
    XCTAssertEqual(conniemovie, [three payer], @"Payer not equal to the person that should pay.");
    XCTAssertEqualWithAccuracy([@19.00 doubleValue], [[three money] doubleValue], 0.001, @"Amount of money not equal to what should be paid.");
    XCTAssertEqual(liekemovie, [two receiver], @"Receiver not equal to the person that should receive.");
    [MCSharedBill deleteSharedbill:event];
    XCTAssertTrue([event isDeleted], @"Movie is not deleted");
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testToCheckIfEmailAddressesAreProperlyDeletedWhenDeletingASharedBill
{
    // This test is to check to see the MCEmailAddressObjects which are of the people on the MCSharedBill are properly deleted.
    MCSharedBill *event = [[MCSharedBill alloc] initWithContext:_context];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    [event setTripName:@"Movie"];
    XCTAssertFalse([event areTherePeople], @"There are people on a new event?");
    MCPerson *markmovie = [eventModel addPerson];
    MCPersonModel *markModel = [[MCPersonModel alloc] initWithPerson:markmovie];
    [markModel.person setFirstName:@"Mark"];
    [markModel.person setLastName:@"Cornelisse"];
    [markModel addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    MCEmailAddress *marksOnlyEmailAddress = [[markmovie emailAddress] anyObject];
    [MCSharedBill deleteSharedbill:event];
    XCTAssertTrue([marksOnlyEmailAddress isDeleted], @"marks email address is not properly deleted.");
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testToCheckCalculationWhenEverybodyIsNotPresentOnPayment
{
    // This test is to check to see if the - (NSArray *)solveWhoHasToPayWhoFromThisBill still solves the bill correctly if there is a payment present no presences.
    MCSharedBill *event = [MCSharedBill addSharedBillToContext:_context];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    [event setTripName:@"No presences test."];
    MCPerson *mark = [eventModel addPerson];
    MCPersonModel *markModel = [[MCPersonModel alloc] initWithPerson:mark];
    [markModel.person setFirstName:@"Mark"];
    [markModel.person setLastName:@"Cornelisse"];
    [markModel addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    MCPerson *ilse = [eventModel addPerson];
    MCPersonModel *ilseModel = [[MCPersonModel alloc] initWithPerson:ilse];
    [ilseModel.person setFirstName:@"Ilse"];
    [ilseModel.person setLastName:@"Beguin"];
    [ilseModel addOneEmailAddressFromAString:@"ilse.beguin@hotmail.com"];
    MCPayment *paymentWithNoPresences = [eventModel addPayment];
    MCPaymentModel *paymentWithNoPresencesModel = [[MCPaymentModel alloc] initWithPayment:paymentWithNoPresences];
    [paymentWithNoPresences setMoney:@6.00];
    [paymentWithNoPresences setPayingPerson:ilse];
    [paymentWithNoPresences setDescriptionOfPayment:@"Nobody is present on this payment."];
    for (MCPaymentPresence *paymentPresence in [paymentWithNoPresences peopleSharingPayment]) {
        [paymentPresence setIsPersonPresent:@NO];
    }
    [paymentWithNoPresencesModel recalculateAveragePeopleOweAndStore];
    MCPayment *paymentWithPresences = [eventModel addPayment];
    MCPaymentModel *paymentWithPresencesModel = [[MCPaymentModel alloc] initWithPayment:paymentWithPresences];
    paymentWithPresences.money = @5.00;
    paymentWithPresences.payingPerson = mark;
    paymentWithPresences.descriptionOfPayment = @"Everybody is present on this payment.";
    paymentWithPresences.currency = event.mainCurrency;
    [paymentWithPresencesModel recalculateAveragePeopleOweAndStore];
    NSArray *result = [event solveWhoHasToPayWhoFromThisBill];
    XCTAssertTrue([result count] == 1, @"There should be one solution.");
    MCReturnPayment *returnPayment = [result lastObject];
    XCTAssertEqualWithAccuracy([[returnPayment money] doubleValue], 2.5, 0.001, @"The amount of money owed should be 2.5");
    XCTAssertTrue([returnPayment payer] == ilse, @"Ilse should be paying.");
    XCTAssertTrue([returnPayment receiver] == mark, @"Mark should be receiving.");
    XCTAssertEqualWithAccuracy([[event totalSumOfMoneyOfThisSharedBill] doubleValue], 5.00, 0.001, @"A total of 5 spent should be present.");
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testDeleteIfStillNew
{
    MCSharedBill *event = [MCSharedBill addSharedBillToContext:_context];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    
    [event deleteIfStillNew];
    XCTAssertTrue([event isDeleted], @"tonightsBill should be deleted when tripname is nil, people present count is 0 and payment counts is 0.");
    [eventModel reset];
    
    event = [MCSharedBill addSharedBillToContext:_context];
    eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    [event setTripName:@""];
    [event deleteIfStillNew];
    XCTAssertTrue([event isDeleted], @"tonightsBill should be deleted when tripName length is 0 characters, people present count is 0 and payments count is 0.");
    [eventModel reset];
    
    event = [MCSharedBill addSharedBillToContext:_context];
    eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    [event setTripName:@"Strip club"];
    [event deleteIfStillNew];
    XCTAssertFalse([event isDeleted], @"tonightsbill should not be deleted when tripname is present.");
    [MCSharedBill deleteSharedbill:event];
    [eventModel reset];
    
    event = [MCSharedBill addSharedBillToContext:_context];
    eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    MCPerson *person = [eventModel addPerson];
    [eventModel deleteIfStillNew];
    XCTAssertFalse([event isDeleted], @"tonightsbill should not be deleted when a person is present.");
    [MCSharedBill deleteSharedbill:event];
    [eventModel reset];
    
    event = [MCSharedBill addSharedBillToContext:_context];
    eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    MCPayment *payment = [eventModel addPayment];
    [eventModel deleteIfStillNew];
    XCTAssertFalse([event isDeleted], @"tonightsbill should not be deleted when a person is present.");
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testmainCurrency
{
    // This test validates the adding of the default currency
    MCSharedBill *tonightsBill = [MCSharedBill addSharedBillToContext:_context];
    NSString *currentLocaleCurrencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
    XCTAssertTrue([[[tonightsBill mainCurrency] code] isEqualToString:currentLocaleCurrencyCode], @"%@ is not equal to %@", [[tonightsBill mainCurrency] code], currentLocaleCurrencyCode);
}

- (void)testInitialPaymentCurrency
{
    MCSharedBill *event = [MCSharedBill addSharedBillToContext:_context];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    MCPayment *thisPayment = [eventModel addPayment];
    NSString *currentLocaleCurrencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
    XCTAssertTrue([[[thisPayment currency] code] isEqualToString:currentLocaleCurrencyCode], @"%@ is not equal to %@", [[thisPayment currency] code], currentLocaleCurrencyCode);
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testAmountShouldHavePaidBy
{
    // Test to see if amountShouldHavePaidBy delivers the correct amount.
    MCSharedBill *event = [MCSharedBill addSharedBillToContext:_context];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    MCCurrency *mainCurrency = [currencyModel currencyFromCurrencyCode:@"EUR"];
    MCPerson *mieke = [eventModel addPerson];
    [mieke setFirstName:@"Mieke"];
    [mieke setLastName:@"Mooi"];
    MCPerson *anne = [eventModel addPerson];
    [anne setFirstName:@"Anne"];
    [anne setLastName:@"Lief"];
    MCPerson *mark = [eventModel addPerson];
    [mark setFirstName:@"Mark"];
    [mark setLastName:@"De grootte"];
    MCCurrency *currencyFirstPayment = [currencyModel currencyFromCurrencyCode:@"USD"];
    MCPayment *firstPayment = [eventModel addPayment];
    MCPaymentModel *payment1Model = [[MCPaymentModel alloc] initWithPayment:firstPayment];
    [firstPayment setDescriptionOfPayment:@"Movie"];
    [firstPayment setPayingPerson:mark];
    [firstPayment setMoney:@32.00];
    [firstPayment setCurrency:currencyFirstPayment];
    [payment1Model recalculateAveragePeopleOweAndStore];
    MCExchangeRate *usdToEur = [[MCExchangeRate alloc] initWithContext:_context];
    usdToEur.toCurrency = mainCurrency;
    usdToEur.fromCurrency = currencyFirstPayment;
    usdToEur.exchangeRate = @0.742;
    [firstPayment setExchangeRate:usdToEur];
    NSNumber *amountMiekeShouldPay = [event amountShouldHavePaidBy:mieke];
    XCTAssertEqualWithAccuracy([@(32.00 * 0.742 / 3.0) doubleValue], [amountMiekeShouldPay doubleValue], 0.001, @"Mieke should pay something else?");
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testOriginalSolveWhoHasToPayWhoFromThisBill
{
    // Test to see if calculation containing foreign currency is done the right way.
    MCSharedBill *event = [MCSharedBill addSharedBillToContext:_context];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    MCCurrency *mainCurrency = [currencyModel currencyFromCurrencyCode:@"EUR"];
    MCPerson *mieke = [eventModel addPerson];
    [mieke setFirstName:@"Mieke"];
    [mieke setLastName:@"Mooi"];
    MCPerson *anne = [eventModel addPerson];
    [anne setFirstName:@"Anne"];
    [anne setLastName:@"Lief"];
    MCPerson *mark = [eventModel addPerson];
    [mark setFirstName:@"Mark"];
    [mark setLastName:@"Leuk"];
    MCCurrency *currencyFirstPayment = [currencyModel currencyFromCurrencyCode:@"USD"];
    MCPayment *firstPayment = [eventModel addPayment];
    MCPaymentModel *payment1Model = [[MCPaymentModel alloc] initWithPayment:firstPayment];
    [firstPayment setDescriptionOfPayment:@"Movie"];
    [firstPayment setPayingPerson:mark];
    [firstPayment setMoney:@30.0];
    [firstPayment setCurrency:currencyFirstPayment];
    [payment1Model recalculateAveragePeopleOweAndStore];
    MCExchangeRate *usdToEur = [[MCExchangeRate alloc] initWithContext:_context];
    usdToEur.toCurrency = mainCurrency;
    usdToEur.fromCurrency = currencyFirstPayment;
    usdToEur.exchangeRate = @0.72;
    firstPayment.exchangeRate = usdToEur;
    NSArray *resultsWithOnlyOnePayment = [event solveWhoHasToPayWhoFromThisBill];
    for (MCReturnPayment *rp in resultsWithOnlyOnePayment) {
        XCTAssertEqualWithAccuracy([[rp money] doubleValue], [@(30.0 * 0.72 / 3) doubleValue], 0.001, @"Basic split amount with conversion not ok.");
    }
    MCCurrency *currencySecondPayment = [currencyModel currencyFromCurrencyCode:@"GBP"];
    MCPayment *secondPayment = [eventModel addPayment];
    MCPaymentModel *payment2Model = [[MCPaymentModel alloc] initWithPayment:secondPayment];
    [secondPayment setDescriptionOfPayment:@"Drinks"];
    [secondPayment setPayingPerson:anne];
    [secondPayment setMoney:@14.50];
    [secondPayment setCurrency:currencySecondPayment];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPaymentPresence"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"payment = %@ AND person.firstName = %@", secondPayment, [mieke firstName]];
    [request setPredicate:predicate];
    NSError *fetchError;
    NSArray *arrayWithOnlyMiekesPaymentPresence = [_context executeFetchRequest:request error:&fetchError];
    XCTAssertNil(fetchError, @"Fetch error: %@", [fetchError localizedDescription]);
    XCTAssertEqual([arrayWithOnlyMiekesPaymentPresence count], 1, @"More than one Mieke present.");
    MCPaymentPresence *miekesPaymentPresence = [arrayWithOnlyMiekesPaymentPresence firstObject];
    [miekesPaymentPresence setIsPersonPresent:@NO];
    [payment2Model recalculateAveragePeopleOweAndStore];
    MCExchangeRate *gbpToEur = [[MCExchangeRate alloc] initWithContext:_context];
    [gbpToEur setToCurrency:mainCurrency];
    [gbpToEur setFromCurrency:currencySecondPayment];
    [gbpToEur setExchangeRate:@1.2625];
    [secondPayment setExchangeRate:gbpToEur];
    NSArray *results = [event solveWhoHasToPayWhoFromThisBill];
    for (MCReturnPayment *returnPayment in results) {
        if ([[[returnPayment receiver] firstName] isEqualToString:@"Anne"]) {
            XCTAssertEqualWithAccuracy([[returnPayment money] doubleValue], [@(14.50*1.2625 - ((14.50 * 1.2625/2) + (30*0.72/3))) doubleValue], 0.001, @"Anne is not receiving the right amount.");
        } else if ([[[returnPayment receiver] firstName] isEqualToString:@"Mark"]) {
            XCTAssertEqualWithAccuracy([[returnPayment money] doubleValue], [@(30.0 * 0.72 - ((14.50 * 1.2625/2) + (30*0.72/3))) doubleValue], 0.001, @"Mark is not receiving the right amount.");
        } else {
            XCTAssertFalse([[[returnPayment receiver] firstName] isEqualToString:@"Mieke"], @"Mieke should not be a receiver of money.");
        }
    }
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)solveWhoHasToPayWhoFromThisBillWithCompletionBlock
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"solveWhoHasToPayWhoFromThisBillWithCompletionBlock"];
    
    // Test to see if calculation containing foreign currency is done the right way.
    MCSharedBill *event = [MCSharedBill addSharedBillToContext:_context];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    MCCurrency *mainCurrency = [currencyModel currencyFromCurrencyCode:@"EUR"];
    MCPerson *mieke = [eventModel addPerson];
    [mieke setFirstName:@"Mieke"];
    [mieke setLastName:@"Mooi"];
    MCPerson *anne = [eventModel addPerson];
    [anne setFirstName:@"Anne"];
    [anne setLastName:@"Lief"];
    MCPerson *mark = [eventModel addPerson];
    [mark setFirstName:@"Mark"];
    [mark setLastName:@"Leuk"];
    MCCurrency *currencyFirstPayment = [currencyModel currencyFromCurrencyCode:@"USD"];
    MCPayment *firstPayment = [eventModel addPayment];
    MCPaymentModel *payment1Model = [[MCPaymentModel alloc] initWithPayment:firstPayment];
    [firstPayment setDescriptionOfPayment:@"Movie"];
    [firstPayment setPayingPerson:mark];
    [firstPayment setMoney:@30.0];
    [firstPayment setCurrency:currencyFirstPayment];
    [payment1Model recalculateAveragePeopleOweAndStore];
    MCExchangeRate *usdToEur = [[MCExchangeRate alloc] initWithContext:_context];
    [usdToEur setToCurrency:mainCurrency];
    [usdToEur setFromCurrency:currencyFirstPayment];
    [usdToEur setExchangeRate:@0.72];
    [firstPayment setExchangeRate:usdToEur];
    NSArray *resultsWithOnlyOnePayment = [event solveWhoHasToPayWhoFromThisBill];
    for (MCReturnPayment *rp in resultsWithOnlyOnePayment) {
        XCTAssertEqualWithAccuracy([[rp money] doubleValue], [@(30.0 * 0.72 / 3) doubleValue], 0.001, @"Basic split amount with conversion not ok.");
    }
    MCCurrency *currencySecondPayment = [currencyModel currencyFromCurrencyCode:@"GBP"];
    MCPayment *secondPayment = [eventModel addPayment];
    MCPaymentModel *payment2Model = [[MCPaymentModel alloc] initWithPayment:secondPayment];
    [secondPayment setDescriptionOfPayment:@"Drinks"];
    [secondPayment setPayingPerson:anne];
    [secondPayment setMoney:@14.50];
    [secondPayment setCurrency:currencySecondPayment];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPaymentPresence"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"payment = %@ AND person.firstName = %@", secondPayment, [mieke firstName]];
    [request setPredicate:predicate];
    NSError *fetchError;
    NSArray *arrayWithOnlyMiekesPaymentPresence = [_context executeFetchRequest:request error:&fetchError];
    XCTAssertNil(fetchError, @"Fetch error: %@", [fetchError localizedDescription]);
    XCTAssertEqual([arrayWithOnlyMiekesPaymentPresence count], 1, @"More than one Mieke present.");
    MCPaymentPresence *miekesPaymentPresence = [arrayWithOnlyMiekesPaymentPresence firstObject];
    [miekesPaymentPresence setIsPersonPresent:@NO];
    [payment2Model recalculateAveragePeopleOweAndStore];
    MCExchangeRate *gbpToEur = [[MCExchangeRate alloc] initWithContext:_context];
    [gbpToEur setToCurrency:mainCurrency];
    [gbpToEur setFromCurrency:currencySecondPayment];
    gbpToEur.exchangeRate = nil;
    gbpToEur.status = [NSNumber numberWithShort:MCExchangeRateStatusInvalid];
    [secondPayment setExchangeRate:gbpToEur];
    [event solveWithHandler:^(NSArray *results, NSError *error) {
        XCTAssertNil(error);
        for (MCReturnPayment *returnPayment in results) {
            XCTAssertNotNil(secondPayment.exchangeRate.exchangeRate, @"There should be a value for the exchange rate.");
            double gbpToEurRate = secondPayment.exchangeRate.exchangeRate.doubleValue;
            if ([[[returnPayment receiver] firstName] isEqualToString:@"Anne"]) {
                XCTAssertEqualWithAccuracy([[returnPayment money] doubleValue], [@(14.50*gbpToEurRate - ((14.50 * gbpToEurRate/2) + (30*0.72/3))) doubleValue], 0.001, @"Anne is not receiving the right amount.");
            } else if ([[[returnPayment receiver] firstName] isEqualToString:@"Mark"]) {
                XCTAssertEqualWithAccuracy([[returnPayment money] doubleValue], [@(30.0 * 0.72 - ((14.50 * gbpToEurRate/2) + (30*0.72/3))) doubleValue], 0.001, @"Mark is not receiving the right amount.");
            } else {
                XCTAssertFalse([[[returnPayment receiver] firstName] isEqualToString:@"Mieke"], @"Mieke should not be a receiver of money.");
            }
        }
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:90 handler:^(NSError *error) {
        XCTAssertFalse(error, "Error: %@", error);
    }];
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testAddPaymentAddToCurrencyToExchangeRate
{
    MCSharedBill *event = [MCSharedBill addSharedBillToContext:_context];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    MCPerson *mark = [eventModel addPerson];
    mark.firstName = @"Mark";
    MCPerson *ilse = [eventModel addPerson];
    ilse.firstName = @"Ilse";
    MCPayment *thisPayment = [eventModel addPayment];
    XCTAssertNotNil([[thisPayment exchangeRate] toCurrency], @"toCurrency in ExchangeRate cannot be nil after creation.");
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testAreAllExchangeRatesValid
{
    MCSharedBill *event = [[MCSharedBill alloc] initWithContext:_context];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    MCPerson *mark = [eventModel addPerson];
    mark.firstName = @"Mark";
    MCPerson *ilse = [eventModel addPerson];
    ilse.firstName = @"Ilse";
    MCPayment *paymentWithValidExchangeRate = [eventModel addPayment];
    XCTAssertNotNil(paymentWithValidExchangeRate, @"Should be present.");
    XCTAssertTrue([event areAllExchangeRatesValid], @"All Exchange Rate should be valid.");
    MCPayment *paymentWithInValidExchangeRate = [eventModel addPayment];
    MCCurrency *foreignCurrency = [currencyModel currencyFromCurrencyCode:@"GBP"];
    paymentWithInValidExchangeRate.currency = foreignCurrency;
    XCTAssertNotNil(paymentWithInValidExchangeRate.exchangeRate, @"ExchangeRate should not be nil.");
    paymentWithInValidExchangeRate.exchangeRate.toCurrency = foreignCurrency;
    paymentWithInValidExchangeRate.exchangeRate.status = [NSNumber numberWithShort:MCExchangeRateStatusFetching];
    XCTAssertFalse([event areAllExchangeRatesValid], @"One exchange rate is fetching.");
    paymentWithInValidExchangeRate.exchangeRate.status = [NSNumber numberWithShort:MCExchangeRateStatusInvalid];
    XCTAssertFalse([event areAllExchangeRatesValid], @"One exchange rate is invalid.");
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testFetchPeoplePresentOrderedByAmountPaid
{
    MCSharedBill *event = [[MCSharedBill alloc] initWithContext:_context];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    MCPerson *mark = [eventModel addPerson];
    mark.firstName = @"Mark";
    MCPerson *lieke = [eventModel addPerson];
    lieke.firstName = @"Lieke";
    MCPerson *marieke = [eventModel addPerson];
    marieke.firstName = @"Marieke";
    MCPayment *iceCream = [eventModel addPayment];
    iceCream.payingPerson = marieke;
    iceCream.descriptionOfPayment = @"Ice Cream";
    iceCream.money = @6.00;
    MCPayment *movie = [eventModel addPayment];
    movie.payingPerson = mark;
    movie.descriptionOfPayment = @"Movie";
    movie.money = @36.00;
    MCPayment *hotelRoom = [eventModel addPayment];
    hotelRoom.payingPerson = lieke;
    hotelRoom.descriptionOfPayment = @"Place to sleep";
    hotelRoom.money = @100.00;
    hotelRoom.exchangeRate.exchangeRate = @0.3;
    NSArray *result = [event fetchPeoplePresentOrderedByAmountPaid:YES];
    XCTAssertTrue(result[0] == marieke, @"First person should be Marieke.");
    XCTAssertTrue(result[1] == lieke, @"Second person should be Lieke.");
    XCTAssertTrue(result[2] == mark, @"Third person should be Mark.");
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testFetchPersonWithID
{
    MCSharedBill *event = [[MCSharedBill alloc] initWithContext:_context];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    MCPerson *mark = [eventModel addPerson];
    mark.firstName = @"Mark";
    mark.lastName = @"Cornelisse";
    NSString *uuid = mark.uniquePersonId;
    MCPerson *fetchedSucker = [event fetchPersonWithUniqueID:uuid];
    XCTAssertTrue([fetchedSucker.uniquePersonId isEqualToString:uuid], @"Fetched uuid should be Mark");
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testDoAllPaymentHaveAPayer
{
    MCSharedBill *event = [MCSharedBill addSharedBillToContext:_context];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    MCPerson *mark = [eventModel addPerson];
    mark.firstName = @"Mark";
    MCPerson *merit = [eventModel addPerson];
    merit.firstName = @"Merit";
    MCPayment *payment = [eventModel addPayment];
    payment.money = @1.00;
    payment.descriptionOfPayment = @"Knuffel";
    BOOL noPaymentsWithoutPayers = event.doAllPaymentsHaveAPayer;
    XCTAssertFalse(noPaymentsWithoutPayers, @"There should be a payment without a payer.");
    MCPayment *paymentWithPayer = [eventModel addPayment];
    payment.money = @34.00;
    paymentWithPayer.descriptionOfPayment = @"Massage";
    paymentWithPayer.payingPerson = merit;
    noPaymentsWithoutPayers = event.doAllPaymentsHaveAPayer;
    XCTAssertFalse(noPaymentsWithoutPayers, @"There should be a payment without a payer.");
    payment.payingPerson = mark;
    noPaymentsWithoutPayers = event.doAllPaymentsHaveAPayer;
    XCTAssertTrue(noPaymentsWithoutPayers, @"All payments should have a payer.");
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testGetFirstPaymentWithoutAPayer
{
    MCSharedBill *event = [MCSharedBill addSharedBillToContext:_context];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    MCPerson *mark = [eventModel addPerson];
    mark.firstName = @"Mark";
    MCPerson *merit = [eventModel addPerson];
    merit.firstName = @"Merit";
    MCPayment *paymentWithPayer = [eventModel addPayment];
    paymentWithPayer.descriptionOfPayment = @"Massage";
    paymentWithPayer.payingPerson = merit;
    paymentWithPayer.money = @34.00;
    MCPayment *paymentWithoutAPayer = [eventModel addPayment];
    paymentWithoutAPayer.money = @1.00;
    paymentWithoutAPayer.descriptionOfPayment = @"Knuffel";
    MCPayment *anotherPaymenWithoutAPayer = [eventModel addPayment];
    anotherPaymenWithoutAPayer.money = @13.00;
    anotherPaymenWithoutAPayer.descriptionOfPayment = @"This is crazy!";
    MCPayment *firstPaymentWithoutAPayer = [event getFirstPaymentWithoutAPayer];
    XCTAssertTrue([firstPaymentWithoutAPayer isEqual:paymentWithoutAPayer], @"These two should be the same.");
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

- (void)testRecentUsedForeignCurrencies
{
    MCSharedBill *event = [MCSharedBill addSharedBillToContext:_context];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_context andWithCurrencyController:[[CurrencyController alloc] init]];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    MCPerson *mark = [eventModel addPerson];
    mark.firstName = @"Mark";
    MCPerson *merit = [eventModel addPerson];
    merit.firstName = @"Merit";
    MCCurrency *aud = [currencyModel currencyFromCurrencyCode:@"AUD"];
    MCPayment *payment = [eventModel addPayment];
    payment.payingPerson = mark;
    payment.currency = aud;
    NSError *error;
    MCCurrency *mainCurrency = [currencyModel generateCurrencyFromSelectedLocaleWithError:&error];
    XCTAssertNil(error, @"generateCurrencyFromSelectedLocaleWithError should not generate an error.");
    MCPayment *homePayment = [eventModel addPayment];
    homePayment.payingPerson = merit;
    homePayment.currency = mainCurrency;
    NSArray<MCCurrency *> *foreignCurrencies = [event recentUsedForeignCurrencies:5];

    XCTAssertTrue(foreignCurrencies.count > 0, @"There can only be multiple foreign currencies");
    for (MCCurrency *currency in foreignCurrencies) {
        XCTAssertTrue([currency.code isEqualToString:@"AUD"], @"Only foreign currency should be Australian Dollar");
    }
    
    // Disconnect the eventModel from the event.
    [eventModel reset];
}

@end
