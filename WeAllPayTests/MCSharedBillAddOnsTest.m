//
//  MCSharedBillAddOnsTest.m
//  We all pay
//
//  Created by Mark Cornelisse on 08-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"
#import "MCEmailAddress+addons.h"
#import "MCPayment+addons.h"
#import "MCPaymentPresence+addons.h"
#import "MCReturnPayment.h"
#import "MCCurrency+addons.h"
#import "MCExchangeRate+addons.h"

@interface MCSharedBillAddOnsTest : XCTestCase
{
    MCWeAllPayStoreController *_mainController;
    NSManagedObjectContext *_context;
}

@end

@implementation MCSharedBillAddOnsTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSError *error;
    NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error];
    XCTAssertTrue(persistentStore, @"Something went wrong opening the In Memory Store: %@", [error localizedDescription]);
    _context = [[NSManagedObjectContext alloc] init];
    [_context setPersistentStoreCoordinator:persistentStoreCoordinator];
    
    [MCCurrency addAllAvailableCurrenciesToContext:_context];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMCSharedBillAddOns1
{
//    XCTAssertTrue([MCSharedBill isTableInDatabaseEmpty], @"There is a sharedBill present in the empty table?");
    MCSharedBill *movie = [MCSharedBill addSharedBill];
    [movie setTripName:@"Movie"];
    XCTAssertFalse([movie areTherePeople], @"There are people on a new event?");
    MCPerson *markmovie = [movie addPerson];
    [markmovie setFirstName:@"Mark"];
    [markmovie setLastName:@"Cornelisse"];
    [markmovie addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    [markmovie addOneEmailAddressFromAString:@"support@markcornelisse.nl"];
    MCPerson *ilsemovie = [movie addPerson];
    [ilsemovie setFirstName:@"Ilse"];
    [ilsemovie setLastName:@"Béguin"];
    [ilsemovie addOneEmailAddressFromAString:@"ilse@markcornelisse.nl"];
    MCPerson *conniemovie = [movie addPerson];
    [conniemovie setFirstName:@"Connie"];
    [conniemovie setLastName:@"Carter"];
    [conniemovie addOneEmailAddressFromAString:@"connie@markcornelisse.nl"];
    MCPerson *liekemovie = [movie addPerson];
    [liekemovie setFirstName:@"Lieke"];
    [liekemovie setLastName:@"Koopman"];
    [liekemovie addOneEmailAddressFromAString:@"lieke@markcornelisse.nl"];
    [liekemovie addNewDefaultEmailAddressFromAString:@"liekeNewDefault@markcornelisse.nl"];
    MCPayment *tickets = [movie addPayment];
    [tickets setPayingPerson:markmovie];
    [tickets setMoney:@(8.90*4)];
    [tickets setDescriptionOfPayment:@"Tickets"];
    MCPayment *drinksAndPopcorn = [movie addPayment];
    [drinksAndPopcorn setPayingPerson:liekemovie];
    [drinksAndPopcorn setMoney:@34.40];
    [drinksAndPopcorn setDescriptionOfPayment:@"Drinks and popcorn for the movie."];
    MCPayment *parking = [movie addPayment];
    [parking setPayingPerson:liekemovie];
    [parking setMoney:@6.00];
    [parking setDescriptionOfPayment:@"Parking"];
    XCTAssertTrue([movie areTherePeople], @"There are no people when 4 people should have been added?");
    XCTAssertTrue([movie totalAmountOfPeoplePresent] == 4, @"4 people were added, but the returned amount it not 4?");
    XCTAssertTrue([movie totalAmountOfPeopleWhoHavePaid] == 2, @"Total amount of people who have paid is not 3");
    XCTAssertTrue([[movie totalSumPaidBy:liekemovie] doubleValue] == 40.40, @"Total sum is wrong when adding multiple payments.");
    XCTAssertTrue([[movie totalSumOfMoneyOfThisSharedBill] doubleValue] == 8.90*4+34.40+6.00, @"Total sum is wrong when adding multiple payments.");
    XCTAssertTrue([movie hasPersonPaidSomething:liekemovie], @"This person should have paid something.");
    XCTAssertTrue([movie hasPersonPaidSomething:markmovie], @"This person should have paid something.");
    XCTAssertFalse([movie hasPersonPaidSomething:ilsemovie], @"This person shouldn't have paid something.");
    XCTAssertFalse([movie hasPersonPaidSomething:conniemovie], @"This person shouldn't have paid something.");
    XCTAssertTrue([movie doesEveryoneHaveAnEmailAddress], @"Everyone should have an email address");
    XCTAssertTrue([[movie amountPeopleShouldHavePaid] doubleValue] == (8.90*4+34.40+6.00)/4, @"The average calculated amount is wrong.");
    NSArray *solution = [movie solveWhoHasToPayWhoFromThisBill];
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
    [MCSharedBill deleteSharedbill:movie];
    XCTAssertTrue([movie isDeleted], @"Movie is not deleted");
}

- (void)testToCheckIfEmailAddressesAreProperlyDeletedWhenDeletingASharedBill
{
    // This test is to check to see the MCEmailAddressObjects which are of the people on the MCSharedBill are properly deleted.
    MCSharedBill *movie = [MCSharedBill addSharedBill];
    [movie setTripName:@"Movie"];
    XCTAssertFalse([movie areTherePeople], @"There are people on a new event?");
    MCPerson *markmovie = [movie addPerson];
    [markmovie setFirstName:@"Mark"];
    [markmovie setLastName:@"Cornelisse"];
    [markmovie addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    MCEmailAddress *marksOnlyEmailAddress = [[markmovie emailAddress] anyObject];
    [MCSharedBill deleteSharedbill:movie];
    XCTAssertTrue([marksOnlyEmailAddress isDeleted], @"marks email address is not properly deleted.");
}

- (void)testToCheckCalculationWhenEverybodyIsNotPresentOnPayment
{
    // This test is to check to see if the - (NSArray *)solveWhoHasToPayWhoFromThisBill still solves the bill correctly if there is a payment present no presences.
    MCSharedBill *tonightsBill = [MCSharedBill addSharedBillToContext:_context];
    [tonightsBill setTripName:@"No presences test."];
    MCPerson *mark = [tonightsBill addPerson];
    [mark setFirstName:@"Mark"];
    [mark setLastName:@"Cornelisse"];
    [mark addOneEmailAddressFromAString:@"info@markcornelisse.nl"];
    MCPerson *ilse = [tonightsBill addPerson];
    [ilse setFirstName:@"Ilse"];
    [ilse setLastName:@"Beguin"];
    [ilse addOneEmailAddressFromAString:@"ilse.beguin@hotmail.com"];
    MCPayment *paymentWithNoPresences = [tonightsBill addPayment];
    [paymentWithNoPresences setMoney:@6.00];
    [paymentWithNoPresences setPayingPerson:ilse];
    [paymentWithNoPresences setDescriptionOfPayment:@"Nobody is present on this payment."];
    for (MCPaymentPresence *paymentPresence in [paymentWithNoPresences peopleSharingPayment]) {
        [paymentPresence setIsPersonPresent:@NO];
    }
    [paymentWithNoPresences recalculateAveragePeopleOweAndStore];
    MCPayment *paymentWithPresences = [tonightsBill addPayment];
    [paymentWithPresences setMoney:@5.00];
    [paymentWithPresences setPayingPerson:mark];
    [paymentWithPresences setDescriptionOfPayment:@"Everybody is present on this payment."];
    NSArray *result = [tonightsBill solveWhoHasToPayWhoFromThisBill];
    XCTAssertTrue([result count] == 1, @"There should be one solution.");
    MCReturnPayment *returnPayment = [result lastObject];
    XCTAssertEqualWithAccuracy([[returnPayment money] doubleValue], 2.5, 0.001, @"The amount of money owed should be 2.5");
    XCTAssertTrue([returnPayment payer] == ilse, @"Ilse should be paying.");
    XCTAssertTrue([returnPayment receiver] == mark, @"Mark should be receiving.");
    XCTAssertEqualWithAccuracy([[tonightsBill totalSumOfMoneyOfThisSharedBill] doubleValue], 5.00, 0.001, @"A total of 5 spent should be present.");
}

- (void)testDeleteIfStillNew
{
    MCSharedBill *tonightsBill = [MCSharedBill addSharedBillToContext:_context];
    [tonightsBill deleteIfStillNew];
    XCTAssertTrue([tonightsBill isDeleted], @"tonightsBill should be deleted when tripname is nil, people present count is 0 and payment counts is 0.");
    
    tonightsBill = [MCSharedBill addSharedBillToContext:_context];
    [tonightsBill setTripName:@""];
    [tonightsBill deleteIfStillNew];
    XCTAssertTrue([tonightsBill isDeleted], @"tonightsBill should be deleted when tripName length is 0 characters, people present count is 0 and payments count is 0.");
    
    tonightsBill = [MCSharedBill addSharedBillToContext:_context];
    [tonightsBill setTripName:@"Strip club"];
    [tonightsBill deleteIfStillNew];
    XCTAssertFalse([tonightsBill isDeleted], @"tonightsbill should not be deleted when tripname is present.");
    [MCSharedBill deleteSharedbill:tonightsBill];
    
    tonightsBill = [MCSharedBill addSharedBillToContext:_context];
    [tonightsBill addPerson];
    [tonightsBill deleteIfStillNew];
    XCTAssertFalse([tonightsBill isDeleted], @"tonightsbill should not be deleted when a person is present.");
    [MCSharedBill deleteSharedbill:tonightsBill];
    
    tonightsBill = [MCSharedBill addSharedBillToContext:_context];
    [tonightsBill addPayment];
    [tonightsBill deleteIfStillNew];
    XCTAssertFalse([tonightsBill isDeleted], @"tonightsbill should not be deleted when a person is present.");
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
    MCSharedBill *tonightsBill = [MCSharedBill addSharedBillToContext:_context];
    MCPayment *thisPayment = [tonightsBill addPayment];
    NSString *currentLocaleCurrencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
    XCTAssertTrue([[[thisPayment currency] code] isEqualToString:currentLocaleCurrencyCode], @"%@ is not equal to %@", [[thisPayment currency] code], currentLocaleCurrencyCode);
}

- (void)testAmountShouldHavePaidBy
{
    // Test to see if amountShouldHavePaidBy delivers the correct amount.
    MCSharedBill *tonightsBill = [MCSharedBill addSharedBillToContext:_context];
    MCCurrency *mainCurrency = [MCCurrency getCurrencyWithCode:@"EUR" FromContext:_context];
    MCPerson *mieke = [tonightsBill addPerson];
    [mieke setFirstName:@"Mieke"];
    [mieke setLastName:@"Mooi"];
    MCPerson *anne = [tonightsBill addPerson];
    [anne setFirstName:@"Anne"];
    [anne setLastName:@"Lief"];
    MCPerson *mark = [tonightsBill addPerson];
    [mark setFirstName:@"Mark"];
    [mark setLastName:@"De grootte"];
    MCCurrency *currencyFirstPayment = [MCCurrency getCurrencyWithCode:@"USD" FromContext:_context];
    MCPayment *firstPayment = [tonightsBill addPayment];
    [firstPayment setDescriptionOfPayment:@"Movie"];
    [firstPayment setPayingPerson:mark];
    [firstPayment setMoney:@32.00];
    [firstPayment setCurrency:currencyFirstPayment];
    [firstPayment recalculateAveragePeopleOweAndStore];
    MCExchangeRate *usdToEur = [MCExchangeRate addExchangeRateForContext:_context];
    [usdToEur setToCurrency:mainCurrency];
    [usdToEur setFromCurrency:currencyFirstPayment];
    [usdToEur setExchangeRate:@0.742];
    [firstPayment setExchangeRate:usdToEur];
    NSNumber *amountMiekeShouldPay = [tonightsBill amountShouldHavePaidBy:mieke];
    XCTAssertEqualWithAccuracy([@(32.00 * 0.742 / 3.0) doubleValue], [amountMiekeShouldPay doubleValue], 0.001, @"Mieke should pay something else?");
}

- (void)testOriginalSolveWhoHasToPayWhoFromThisBill
{
    // Test to see if calculation containing foreign currency is done the right way.
    MCSharedBill *tonightsBill = [MCSharedBill addSharedBillToContext:_context];
    MCCurrency *mainCurrency = [MCCurrency getCurrencyWithCode:@"EUR" FromContext:_context];
    MCPerson *mieke = [tonightsBill addPerson];
    [mieke setFirstName:@"Mieke"];
    [mieke setLastName:@"Mooi"];
    MCPerson *anne = [tonightsBill addPerson];
    [anne setFirstName:@"Anne"];
    [anne setLastName:@"Lief"];
    MCPerson *mark = [tonightsBill addPerson];
    [mark setFirstName:@"Mark"];
    [mark setLastName:@"Leuk"];
    MCCurrency *currencyFirstPayment = [MCCurrency getCurrencyWithCode:@"USD" FromContext:_context];
    MCPayment *firstPayment = [tonightsBill addPayment];
    [firstPayment setDescriptionOfPayment:@"Movie"];
    [firstPayment setPayingPerson:mark];
    [firstPayment setMoney:@30.0];
    [firstPayment setCurrency:currencyFirstPayment];
    [firstPayment recalculateAveragePeopleOweAndStore];
    MCExchangeRate *usdToEur = [MCExchangeRate addExchangeRateForContext:_context];
    [usdToEur setToCurrency:mainCurrency];
    [usdToEur setFromCurrency:currencyFirstPayment];
    [usdToEur setExchangeRate:@0.72];
    [firstPayment setExchangeRate:usdToEur];
    NSArray *resultsWithOnlyOnePayment = [tonightsBill solveWhoHasToPayWhoFromThisBill];
    for (MCReturnPayment *rp in resultsWithOnlyOnePayment) {
        XCTAssertEqualWithAccuracy([[rp money] doubleValue], [@(30.0 * 0.72 / 3) doubleValue], 0.001, @"Basic split amount with conversion not ok.");
    }
    MCCurrency *currencySecondPayment = [MCCurrency getCurrencyWithCode:@"GBP" FromContext:_context];
    MCPayment *secondPayment = [tonightsBill addPayment];
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
    [secondPayment recalculateAveragePeopleOweAndStore];
    MCExchangeRate *gbpToEur = [MCExchangeRate addExchangeRateForContext:_context];
    [gbpToEur setToCurrency:mainCurrency];
    [gbpToEur setFromCurrency:currencySecondPayment];
    [gbpToEur setExchangeRate:@1.2625];
    [secondPayment setExchangeRate:gbpToEur];
    NSArray *results = [tonightsBill solveWhoHasToPayWhoFromThisBill];
    for (MCReturnPayment *returnPayment in results) {
        if ([[[returnPayment receiver] firstName] isEqualToString:@"Anne"]) {
            XCTAssertEqualWithAccuracy([[returnPayment money] doubleValue], [@(14.50*1.2625 - ((14.50 * 1.2625/2) + (30*0.72/3))) doubleValue], 0.001, @"Anne is not receiving the right amount.");
        } else if ([[[returnPayment receiver] firstName] isEqualToString:@"Mark"]) {
            XCTAssertEqualWithAccuracy([[returnPayment money] doubleValue], [@(30.0 * 0.72 - ((14.50 * 1.2625/2) + (30*0.72/3))) doubleValue], 0.001, @"Mark is not receiving the right amount.");
        } else {
            XCTAssertFalse([[[returnPayment receiver] firstName] isEqualToString:@"Mieke"], @"Mieke should not be a receiver of money.");
        }
    }
}

@end
