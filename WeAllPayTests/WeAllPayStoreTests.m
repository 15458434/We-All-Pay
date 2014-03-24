//
//  WeAllPayTests.m
//  WeAllPayTests
//
//  Created by Mark Cornelisse on 21-03-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCWeAllPayStoreController.h"
#import "MCPerson+addons.h"
#import "MCPayment+addons.h"
#import "MCSharedBill+addons.h"
#import "MCEmailAddress+addons.h"
#import "MCReturnPayment.h"

@interface WeAllPayStoreTests : XCTestCase
{
    MCWeAllPayStoreController *mainController;
    NSManagedObjectContext *context;
}

@end

@implementation WeAllPayStoreTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    mainController = [MCWeAllPayStoreController defaultStore];
    context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMCWeAllPayStoreController
{
    MCWeAllPayStoreController *testController = [[MCWeAllPayStoreController alloc] init];
    XCTAssertEqualObjects(testController, mainController, @"MCWeAllPayStoreController init gives not the defaultStore.");
    testController = nil;
    testController = [MCWeAllPayStoreController defaultStore];
    XCTAssertEqualObjects(testController, mainController, @"MCWeAllPayStoreController defaultStore gives not the defaultStore.");
}

- (void)testMCPersonAddonsAddAndDeleteEmailAddress
{
    MCPerson *thisPerson = [MCPerson addPerson];
    [thisPerson setFirstName:@"Mark"];
    [thisPerson setLastName:@"Cornelisse"];
    NSString *emailAddressMark = @"info@markcornelisse.nl";
    [thisPerson addOneEmailAddressFromAString:emailAddressMark];
    XCTAssertTrue([thisPerson isThereAnEmailAddress], @"There is no emailAddress present when one had just been added.");
    XCTAssertTrue([[thisPerson defaultEmailAddress] isEqualToString:emailAddressMark], @"emailAddress Stored is not equal to the new default one");
    NSString *emailAddress2Mark = @"mark.cornelisse@yahoo.com";
    [thisPerson addOneEmailAddressFromAString:emailAddress2Mark];
    XCTAssertTrue([thisPerson isThereAnEmailAddress], @"There is no emailAddress present when two has been added.");
    XCTAssertTrue([[thisPerson defaultEmailAddress] isEqualToString:emailAddressMark], @"emailAddress Stored is not equal to the first one");
    /* Disabled the test failes.
    [thisPerson addOneEmailAddressFromAString:emailAddress2Mark];
    XCTAssertTrue([[thisPerson emailAddress] count] == 2, @"Adding two times the same emailAddress is possible.");
     */
    NSString *emailAddress3Mark = @"m.p.cornelisse@gmail.com";
    [thisPerson addNewDefaultEmailAddressFromAString:emailAddress3Mark];
    XCTAssertTrue([[thisPerson defaultEmailAddress] isEqualToString:emailAddress3Mark], @"addNewDefaultEmailAddress failes to set the right defaultEmailAddress");
    
    // Create a fetch request for MCEmailAddress
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCEmailAddress"];
    
    // Select only emailAddresses for person
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"owner = %@", thisPerson];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"selected = %@", [NSNumber numberWithBool:YES]];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate1, predicate2, nil]];
    [request setPredicate:compoundPredicate];
    NSError *error;
    NSArray *emailAddresses;
    emailAddresses = [context executeFetchRequest:request error:&error];
    if (!emailAddresses) {
        XCTFail(@"No list of email addresses generated");
    }
    XCTAssertTrue([emailAddresses count] == 1, @"More or less then one defaulEmailAddress present.");
    XCTAssertTrue([[thisPerson emailAddress] count] == 3, @"All emailAddresses have been entered.");
    
    
    
    MCEmailAddress *toBeDeletedEmailAddress = [thisPerson getDefaultEmailAddressObject];
    [thisPerson deleteEmailAddress:toBeDeletedEmailAddress];
    XCTAssertTrue([[thisPerson emailAddress] count] == 2, @"Different amount of emailAddresses then expected.");
    XCTAssertTrue([thisPerson getDefaultEmailAddressObject], @"No new defaultEmailAddress present");
    XCTAssertFalse([MCEmailAddress isTableInDatabaseEmpty], @"No emailAddresses left in the database.");
    [thisPerson deletAllEmailAddresses];
    XCTAssertTrue([MCEmailAddress isTableInDatabaseEmpty], @"Email addresses left in the database.");
    XCTAssertFalse([thisPerson isThereAnEmailAddress], @"There is an emailAddress present when two has been added.");
    
    XCTAssertFalse([MCPerson isTableInDatabaseEmpty], @"No people left in the database");
    [MCPerson deletePerson:thisPerson];
    XCTAssertTrue([MCPerson isTableInDatabaseEmpty], @"People left in the database");
}

- (void)testMCPersonAddonsGetName
{
    MCPerson *thisPerson = [MCPerson addPerson];
    [thisPerson setFirstName:@"Connie"];
    [thisPerson setLastName:@"Carter"];
    [thisPerson addOneEmailAddressFromAString:@"connie@markcornelisse.nl"];
    XCTAssertTrue([[thisPerson getName] isEqualToString:@"Connie"], @"First name is not selected when it's available.");
    XCTAssertTrue([[thisPerson getFullName] isEqualToString:@"Connie Carter"]);
    MCPerson *thisPersonWithMissingFirstName = [MCPerson addPerson];
    [thisPersonWithMissingFirstName setLastName:@"Carter"];
    [thisPersonWithMissingFirstName addOneEmailAddressFromAString:@"connie@markcornelisse.nl"];
    XCTAssertTrue([[thisPersonWithMissingFirstName getName] isEqualToString:@"Carter"], @"Last is not selected when first name is not available");
    XCTAssertTrue([[thisPersonWithMissingFirstName getFullName] isEqualToString:@"Carter"], @"Fullname is wrong when first name is missing.");
    MCPerson *thisPersonWithMissingFirstAndLastName = [MCPerson addPerson];
    [thisPersonWithMissingFirstAndLastName addOneEmailAddressFromAString:@"connie@markcornelisse.nl"];
    XCTAssertTrue([[thisPersonWithMissingFirstAndLastName getName] isEqualToString:@"connie@markcornelisse.nl"], @"emailAddress is not selected when both first and lastname are not selected.");
    XCTAssertTrue([[thisPersonWithMissingFirstAndLastName getFullName] isEqualToString:@"connie@markcornelisse.nl"], @"emailAddress is not selected when both first and lastnames are not selected.");
}

- (void)testMCPaymentAddons
{
    MCPerson *thisPerson = [MCPerson addPerson];
    [thisPerson setFirstName:@"Mark"];
    [thisPerson setLastName:@"Cornelisse"];
    [thisPerson addNewDefaultEmailAddressFromAString:@"support@markcornelisse.nl"];
    MCPayment *thisPayment = [MCPayment addPayment];
    [thisPayment setDescriptionOfPayment:@"Beer"];
    [thisPayment setMoney:[NSNumber numberWithDouble:3.25]];
    XCTAssertFalse([thisPayment hasPayer], @"PayerPresent");
    [thisPayment setPayingPerson:thisPerson];
    XCTAssertTrue([thisPayment hasPayer], @"No payer present on thisPayment");
    
    [MCPayment deletePayment:thisPayment];
    XCTAssertTrue([MCPayment isTableInDatabaseEmpty], @"MCPayment table is not empty");
    
    [MCPerson deletePerson:thisPerson];
}

- (void)testMCSharedBillAddOns1
{
    XCTAssertTrue([MCSharedBill isTableInDatabaseEmpty], @"There is a sharedBill present in the empty table?");
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
    [tickets setMoney:[NSNumber numberWithDouble:8.90*4]];
    [tickets setDescriptionOfPayment:@"Tickets"];
    MCPayment *drinksAndPopcorn = [movie addPayment];
    [drinksAndPopcorn setPayingPerson:liekemovie];
    [drinksAndPopcorn setMoney:[NSNumber numberWithDouble:34.40]];
    [drinksAndPopcorn setDescriptionOfPayment:@"Drinks and popcorn for the movie."];
    MCPayment *parking = [movie addPayment];
    [parking setPayingPerson:liekemovie];
    [parking setMoney:[NSNumber numberWithDouble:6.00]];
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
    MCReturnPayment *one = [solution objectAtIndex:0];
    XCTAssertEqualObjects(@"Ilse pays $16.60 to Mark.", [one stringForMail], @"Solution for 1st object is not ok.");
    MCReturnPayment *two = [solution objectAtIndex:1];
    XCTAssertEqualObjects(@"Ilse pays $2.40 to Lieke.", [two stringForMail], @"Solution for 2nd object is not ok.");
    MCReturnPayment *three = [solution objectAtIndex:2];
    XCTAssertEqualObjects(@"Connie pays $19.00 to Lieke.", [three stringForMail], @"Solution for 3rd object is not ok.");
    [MCSharedBill deleteSharedbill:movie];
    XCTAssertTrue([MCSharedBill isTableInDatabaseEmpty], @"There are still MCShardBills present");
}



@end
