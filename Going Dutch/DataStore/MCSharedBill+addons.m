//
//  MCSharedBill+addons.m
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"
#import "MCEmailAddress+addons.h"
#import "MCPayment+addons.h"
#import "MCPaymentPresence+addons.h"
#import "MCWeAllPayStoreController.h"
#import "MCReturnPayment.h"
#import "MCCurrency+addons.h"
#import "MCExchangeRate+addons.h"

#import "We_all_pay-Swift.h"

@implementation MCSharedBill (addons)

#pragma mark - New in this class.

+ (MCSharedBill *)addSharedBill
{
    NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
    return [MCSharedBill addSharedBillToContext:context];
}

+ (MCSharedBill *)addSharedBillToContext:(NSManagedObjectContext *)context
{
    MCSharedBill *sharedBill;
    sharedBill = [NSEntityDescription insertNewObjectForEntityForName:@"MCSharedBill" inManagedObjectContext:context];
    [sharedBill setUniqueBillId:[MCTools createUniqueIdentifierString]];
    [sharedBill setHasTheMailBeenSent:@NO];
    NSDate *nu = [NSDate date];
    [sharedBill setDateCreated:nu];
    [sharedBill setDateModified:nu];
    [sharedBill setMainCurrency:[MCCurrency generateCurrencyFromSelectedLocaleForContext:context]];
    return sharedBill;
}

+ (void)deleteSharedbill:(MCSharedBill *)deleteBill
{
    NSManagedObjectContext *context = [deleteBill managedObjectContext];
    // Delete all paymentPresences of all payments.
    for (MCPayment *payment in [deleteBill payments]) {
        for (MCPaymentPresence *paymentPresence in [payment peopleSharingPayment]) {
            [context deleteObject:paymentPresence];
        }
    }
    // Delete all payments of the to be deleted sharedbill
    for (MCPayment *payment in [deleteBill payments]) {
        [context deleteObject:payment];
    }
    // Delete all emailaddresses of all people of the sharedbill.
    for (MCPerson *person in [deleteBill peoplePresent]) {
        for (MCEmailAddress *emailAddress in [person emailAddress]) {
            [context deleteObject:emailAddress];
        }
    }
    // Delete all people of the sharedbill.
    for (MCPerson *person in [deleteBill peoplePresent]) {
        [context deleteObject:person];
    }
    // Delete the sharedBill itself.
    [context deleteObject:deleteBill];
}

+ (MCSharedBill *)fetchSharedBillWithUniqueId:(NSString *)uuid inContext:(NSManagedObjectContext *)context
{
    // Create a fetch request for MCSharedBills.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCSharedBill"];
    
    // Select only the sharedBill with uuid as uniqueBillId
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueBillId = %@", uuid];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *sharedBills = [context executeFetchRequest:request error:&error];
    if (!sharedBills) {
        // There was an error.
        return nil;
    } else {
        if (sharedBills.count > 0) {
            return sharedBills[0];
        } else {
            return nil;
        }
    }
}

+ (BOOL)isTableInDatabaseEmpty
{
    NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
    return [self isTableInDatabaseEmptyForContext:context];
}

+ (BOOL)isTableInDatabaseEmptyForContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCSharedBill"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES];
    NSArray *sortDescriptorArray = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptorArray];

    NSError *error;
    NSArray *people = [context executeFetchRequest:request error:&error];
    if (people) {
        if ([people count] == 0) {
            return YES;
        } else {
#if DEBUG
            NSLog(@"sharedBills.count should not be 0.");
#endif
            return NO;
        }
    } else {
        return NO;
    }
}

- (NSString *)stringOfApproxPeoplePresent;
{
    NSArray *allPeople = [[self peoplePresent] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]]];
    if ([allPeople count] == 0) {
        return NSLocalizedString(@"NO_PEOPLE_PRESENT", @"A message when there are no people present inside this shared bill");
    } else if ([allPeople count] == 1) {
        return [allPeople[0] getName];
    } else if ([allPeople count] == 2) {
        NSString *enString = [NSString stringWithFormat:NSLocalizedString(@"AND_STRING", @"The word \"and\" between two people")];
        return [NSString stringWithFormat:@"%@ %@ %@", [allPeople[0] getName], enString,[allPeople[1] getName]];
    } else if ([allPeople count] >= 3) {
        NSString *andOthers = [NSString stringWithFormat:NSLocalizedString(@"AND_OTHERS", @"A list of people like Mark, Ilse and other where the \"and others\" needs to be translated.")];
        return [NSString stringWithFormat:@"%@, %@ %@", [allPeople[0] getName], [allPeople[1] getName], andOthers];
    } else {
        @throw [NSException exceptionWithName:@"Negative amount of people." reason:@"Should not be possible." userInfo:nil];
        return nil;
    }
}

- (NSString *)stringOfApproxPeoplePresentWithFullNames;
{
    NSArray *allPeople;
    NSArray *sda = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    allPeople = [[self peoplePresent] sortedArrayUsingDescriptors:sda];
    NSMutableString *returnString = [[NSMutableString alloc] init];
    if ([allPeople count] == 0) {
        return NSLocalizedString(@"NO_PEOPLE_PRESENT", @"A message when there are no people present inside this shared bill");
    } else if ([allPeople count] == 1) {
        return [allPeople[0] getFullName];
    } else if ([allPeople count] == 2) {
        NSString *enString = [NSString stringWithFormat:NSLocalizedString(@"AND_STRING", @"The word \"and\" between two people")];
        [returnString appendFormat:@"%@ %@ %@", [allPeople[0] getFullName], enString,[allPeople[1] getFullName]];
        return returnString;
    } else if ([allPeople count] >= 3) {
        NSString *andOthers = [NSString stringWithFormat:NSLocalizedString(@"AND_OTHERS", @"A list of people like Mark, Ilse and other where the \"and others\" needs to be translated.")];
        [returnString appendFormat:@"%@, %@ %@", [allPeople[0] getFullName], [allPeople[1] getFullName], andOthers];
        return returnString;
    } else {
        @throw [NSException exceptionWithName:@"Negative amount of people." reason:@"Should not be possible." userInfo:nil];
        return nil;
    }
}

- (void)addPeoplePresentObject:(MCPerson *)value
{
    NSMutableSet *mutableListOfPeople = [[self peoplePresent] mutableCopy];
    [mutableListOfPeople addObject:value];
    [self setPeoplePresent:mutableListOfPeople];
}

- (void)removePeoplePresentObject:(MCPerson *)value
{
    NSMutableSet *mutableListOfPeople = [[self peoplePresent] mutableCopy];
    [mutableListOfPeople removeObject:value];
    [self setPeoplePresent:mutableListOfPeople];
}

- (MCPayment *)addPayment
{
    MCPayment *payment = [MCPayment addPaymentInContext:[self managedObjectContext]];
    for (MCPerson *person in [self peoplePresent]) {
        MCPaymentPresence *paymentPresence = [MCPaymentPresence addPaymentPresenceInContext:[self managedObjectContext]];
        [paymentPresence setPayment:payment];
        [paymentPresence setPerson:person];
        [paymentPresence setIsPersonPresent:@YES];
    }
    [payment setOnWhichBill:self];
    payment.exchangeRate.toCurrency = [self mainCurrency];
    return payment;
}

- (void)deletePayment:(MCPayment *)toBeDeletePayment
{
    // It is not allowed to delete a payment belonging to another sharedBill.
    NSParameterAssert([toBeDeletePayment onWhichBill] == self);
    
    // First delete the people presence on payment data.
    NSSet *paymentPresences = [toBeDeletePayment peopleSharingPayment];
    for (MCPaymentPresence *paymentPresence in paymentPresences) {
        [[self managedObjectContext] deleteObject:paymentPresence];
    }
    
    // Then delete the payment.
    [[self managedObjectContext] deleteObject:toBeDeletePayment];
    
}

- (void)updatePaymentForSupportWithPaymentPresence
{
    // Always executed to maintain unit test compatibility.
    for (MCPayment *payment in [self payments]) {
        [payment recalculateAveragePeopleOweAndStore];
    }
}

- (MCPerson *)addPerson
{
    NSManagedObjectContext *context = [self managedObjectContext];
    MCPerson *newPerson = [MCPerson addPersonInContext:context];
    for (MCPayment *payment in [self payments]) {
        // Presence of all the exisiting payments on this sharedBill will be created and set tot NO.
        [payment addLateArrivalPaymentPresenceFor:newPerson];
    }
    [newPerson addSharedBillObject:self];
    return newPerson;
}

- (void)deletePerson:(MCPerson *)toBeDeletedPerson
{
    NSSet *presences = [[toBeDeletedPerson sharingPayment] copy];
    for (MCPaymentPresence *paymentPresence in presences) {
        MCPayment *payment = [paymentPresence payment];
        [[self managedObjectContext] deleteObject:paymentPresence];
        [payment recalculateAveragePeopleOweAndStore];
    }
    [MCPerson deletePerson:toBeDeletedPerson];
}

- (MCPerson *)fetchPersonWithUniqueID:(NSString *)uuid
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"ANY sharedBill = %@ AND uniquePersonId = %@", self, uuid];
    NSError *fetchError;
    NSArray *result = [context executeFetchRequest:request error:&fetchError];
    if (!result) {
        NSLog(@"Error fetching person with id:%@", uuid);
        NSLog(@"%@", fetchError.description);
        return nil;
    } else {
        return result.firstObject;
    }
}

- (BOOL)isPresentWithFirstName:(NSString *)firstName andLastName:(NSString *)lastName andEmailAddress:(NSString *)emailAddress
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    NSArray *sda = @[sortDescriptor1, sortDescriptor2];
    [request setSortDescriptors:sda];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY sharedBill = %@ AND firstName = %@ AND lastName = %@ AND ANY emailAddress.emailAddress = %@", self, firstName, lastName, emailAddress];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *result = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (!result) {
        NSLog(@"Error checking if person is present: %@", [error localizedDescription]);
        return NO;
    } else {
        if ([result count] == 0) {
            return NO;
        } else {
            return YES;
        }
    }
}

- (BOOL)areTherePeople
{
    if ([[self peoplePresent] count] == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (NSUInteger)totalAmountOfPeoplePresent
{
    return [[self peoplePresent] count];
}

- (NSUInteger)totalAmountOfPeopleWhoHavePaid
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
    request.predicate = [NSPredicate predicateWithFormat:@"some payments.onWhichBill == %@", self];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"uniquePersonId" ascending:YES]];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error = nil;
    NSUInteger result = [context countForFetchRequest:request error:&error];
    if (error) {
        NSLog(@"totalAmountOfPeopleWhoHavPaid fetch error: %@", [error localizedDescription]);
        return 0;
    } else {
        return result;
    }
}

- (NSNumber *)totalSumOfMoneyOfThisSharedBill
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    NSArray *paymentsOfThisSharedBill = [self.payments sortedArrayUsingDescriptors:sortDescriptors];
    return [paymentsOfThisSharedBill valueForKeyPath:@"@sum.moneyInMainCurrency"];
}

- (NSString *)totalSumOfMoneyOfThisSharedBillAsCurrencyString
{
    NSNumber *totalSpent = [self totalSumOfMoneyOfThisSharedBill];
    NSNumberFormatter *nf = [[self mainCurrency] numberFormatter];
    return [nf stringFromNumber:totalSpent];
}

- (NSArray *)fetchPeoplePresentOrderedByAmountPaid:(BOOL)ascending
{
    NSSet *people = [self peoplePresent];
    NSArray *sortedPeople = [people sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"totalSumPaid" ascending:ascending] ]];
    return sortedPeople;
}

- (NSNumber *)totalAmountOfCreditBy:(MCPerson *)person
{
    double totalSumPaid = person.totalSumPaid.doubleValue;
    double average = [[self amountPeopleShouldHavePaid] doubleValue];
    double credit = totalSumPaid - average;
    return @(credit);
}

- (BOOL)hasPersonPaidSomething:(MCPerson *)person
{
    NSNumber *paid = person.totalSumPaid;
    if ([paid doubleValue] < 0.01) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)doesEveryoneHaveAnEmailAddress
{
    for (MCPerson *person in [self peoplePresent]) {
        if (![person isThereAnEmailAddress]) {
            return NO;
        }
    }
    return YES;
}

- (NSNumber *)amountPeopleShouldHavePaid
{
    double sumOfMoney = [[self totalSumOfMoneyOfThisSharedBill] doubleValue];
    if ([[self peoplePresent] count] > 0) {
        double average = sumOfMoney / [[self peoplePresent] count];
        return @(average);
    } else {
        return @0.0;
    }
}

- (NSNumber *)amountShouldHavePaidBy:(MCPerson *)person
{
    // Fetch the sum of all paymentPresences for person
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPaymentPresence"];
    request.predicate = [NSPredicate predicateWithFormat:@"payment.onWhichBill = %@ AND person = %@ AND isPersonPresent = %@", self, person, @YES];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"person" ascending:YES]];

    NSError *error;
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Something went wrong fetching sumOfAverageFromEachPayment: %@", error);
    }
    
    double sumOfAllOwes = 0;
    for (MCPaymentPresence *paymentPresence in results) {
        sumOfAllOwes += [[paymentPresence getAverageOweFromPaymentInMainCurrency] doubleValue];
    }
    
    return @(sumOfAllOwes);
}

- (NSString *)amountShouldHavePaidAsCurrencyStringBy:(MCPerson *)person
{
    // Still has no Unit test.
    NSNumber *shouldHavePaid = [self amountShouldHavePaidBy:person];
    NSNumberFormatter *nf = [[self mainCurrency] numberFormatter];
    return [nf stringFromNumber:shouldHavePaid];
}


- (NSString *)amountPeopleShouldHavePaidAsCurrencyString
{
    NSNumber *averageSpentByPerson = [self amountPeopleShouldHavePaid];
    NSNumberFormatter *nf = [[self mainCurrency] numberFormatter];
    [nf setLocale:[NSLocale currentLocale]];
    return [nf stringFromNumber:averageSpentByPerson];
}

- (BOOL)doAllPaymentHaveAPayer
{
    // Query that checks to see if all the payments have a payer.
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MCPayment"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"payingPerson = nil"];
    NSError *fetchError;
    NSUInteger *amountOfPaymentWithoutPayers = [[self managedObjectContext] countForFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"Something went wrong counting payments without payers: %@", fetchError);
    }
    if (amountOfPaymentWithoutPayers > 0) {
        return false;
    } else {
        return true;
    }
}

- (MCPayment *)getFirstPaymentWithoutAPayer
{
    // Returns the first payment without a payer on this sharedBill.
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MCPayment"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"onWhichBill = %@ AND payingPerson = %@", self, nil];
    NSError *fetchError;
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"Error fetching firstPayment without a payer.");
        return nil;
    }
    return (MCPayment *)results.firstObject;
}

- (BOOL)areAllExchangeRatesValid
{
    // Fetch all exchangeRates that are invalid.
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MCExchangeRate"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    
    NSNumber *exchangeRateValidStatus = [NSNumber numberWithShort:valid];
    request.predicate = [NSPredicate predicateWithFormat:@"payment.onWhichBill = %@ and status != %@", self, exchangeRateValidStatus];
    NSError *fetchError;
    NSUInteger *amountOfInvalidExchangeRates = [[self managedObjectContext] countForFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"Something went wrong counting invalid exchangeRates: %@", [fetchError localizedDescription]);
    }
    if (amountOfInvalidExchangeRates == 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)updateInvalidExchangeRatesWithCompletionBlock:(void (^)(NSArray *results))completionBlock
{
    // Fetch all exchangeRates that are invalid.
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MCExchangeRate"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    
    NSNumber *exchangeRateValidStatus = [NSNumber numberWithShort:valid];
    request.predicate = [NSPredicate predicateWithFormat:@"payment.onWhichBill = %@ and status != %@", self, exchangeRateValidStatus];
    NSError *fetchError;
    NSArray *arrayOfInvalidExchangeRatesOfThisSharedBill = [[self managedObjectContext] executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"Something went wrong fetching invalid ExchangeRates: %@", [fetchError localizedDescription]);
    }
    [[[MCWeAllPayStoreController defaultStore] fetcher] fetchAll:arrayOfInvalidExchangeRatesOfThisSharedBill completionHandler:^(NSError * error) {
        if ([self areAllExchangeRatesValid]) {
            completionBlock([self solveWhoHasToPayWhoFromThisBill]);
        }
    }];
}

- (NSArray *)originalSolveWhoHasToPayWhoFromThisBill
{
    // Create two array's one of peope who should pay and one with people that should receive.
    NSMutableArray *payers = [[NSMutableArray alloc] init];
    NSNumber *leftToPay;
    NSNumber *leftToReceive;
    NSMutableArray *receivers = [[NSMutableArray alloc] init];
    NSMutableArray *whoHasToPayWho = [[NSMutableArray alloc] init];
    NSArray *sortDescriptorArray1 = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    NSArray *people = [[self peoplePresent] sortedArrayUsingDescriptors:sortDescriptorArray1];
    
    // Update the database to the current version.
    [self updatePaymentForSupportWithPaymentPresence];
    
    for (MCPerson *person in people) {
        NSLog(@"%@ paid %@", [person getName], person.totalSumPaid);
        NSNumber *sumOfWhatWasPaidByPerson = person.totalSumPaid;
        NSNumber *sumOfWhatShouldBePaidPerson = [self amountShouldHavePaidBy:person];
        
        if ([sumOfWhatWasPaidByPerson doubleValue] < [sumOfWhatShouldBePaidPerson doubleValue]) {
            // This person should pay to someone.
            leftToPay = @([sumOfWhatShouldBePaidPerson doubleValue] - [sumOfWhatWasPaidByPerson doubleValue]);
            NSArray *creditValueOfThisPerson = [[NSMutableArray alloc] initWithObjects:person, sumOfWhatShouldBePaidPerson, sumOfWhatWasPaidByPerson, leftToPay, nil];
            [payers addObject:creditValueOfThisPerson];
        } else if ([sumOfWhatWasPaidByPerson doubleValue] > [sumOfWhatShouldBePaidPerson doubleValue]){
            // This person should receive from someone.
            leftToReceive = @([sumOfWhatWasPaidByPerson doubleValue] - [sumOfWhatShouldBePaidPerson doubleValue]);
            NSArray *creditValueOfThisPerson = [[NSMutableArray alloc] initWithObjects:person, sumOfWhatShouldBePaidPerson, sumOfWhatWasPaidByPerson, leftToReceive, nil];
            [receivers addObject:creditValueOfThisPerson];
        } else {
            // This person has already paid enough.
//            MCReturnPayment *notDepted = [[MCReturnPayment alloc] initWithPayer:person paysTo:nil amountOfMoney:@0.00];
//            [whoHasToPayWho addObject:notDepted];
        }
    }
    
    // Solve who has to pay who.
    if ([payers count] > 0) {
        for (NSMutableArray *payer in payers) {
            for (NSMutableArray *receiver in receivers) {
                double ltp = [payer[3] doubleValue];
                double ltr = [receiver[3] doubleValue];
                MCReturnPayment *returnPayment;
                if (ltp >= ltr) {
                    returnPayment = [[MCReturnPayment alloc] initWithPayer:payer[0] paysTo:receiver[0] amountOfMoney:@(ltr)];
                    ltp -= ltr;
                    ltr = 0;
                } else {
                    returnPayment = [[MCReturnPayment alloc] initWithPayer:payer[0] paysTo:receiver[0] amountOfMoney:@(ltp)];
                    ltr -= ltp;
                    ltp = 0;
                }
                leftToPay = @(ltp);
                leftToReceive = @(ltr);
                payer[3] = leftToPay;
                receiver[3] = leftToReceive;
                
                if ([[returnPayment money] doubleValue] > 0) {
                    [whoHasToPayWho addObject:returnPayment];
                }
            }
        }
    } else {
    }
    return whoHasToPayWho;
}

- (NSArray *)solveWhoHasToPayWhoFromThisBill
{
    return [self originalSolveWhoHasToPayWhoFromThisBill];
}

- (NSArray *)solveWhoHasToPayWhoFromThisBillWithCompletionBlock:(void (^)(NSArray *))completionBlock
{
    // This function will either give an NSArray as return value or it will return nil and will execuute the completionBlock at a later time when all exchangeRates are valid.
    if ([self areAllExchangeRatesValid]) {
        return [self originalSolveWhoHasToPayWhoFromThisBill];
    } else {
        [self updateInvalidExchangeRatesWithCompletionBlock:^(NSArray *results){
            NSArray *result = [self originalSolveWhoHasToPayWhoFromThisBill];
            completionBlock(result);
        }];
        return nil;
    }
}

- (NSArray *)getArrayOfFullNamesOfPeoplePresent
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"getFullName" ascending:YES];
    return [[self peoplePresent] sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (void)deleteIfStillNew
{
    // Check to see if tripname is still 0 in length or nil.
    if (![self tripName] || [[self tripName] length] == 0) {
            // Check to see if payments count is still 0
        if ([[self payments] count] == 0) {
            // Check to see if people present is still 0
            if ([[self peoplePresent] count] == 0) {
                [MCSharedBill deleteSharedbill:self];
            }
        }
    }
}

#pragma mark - NSManagedObject Stuff

@end
