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

@implementation MCSharedBill (addons)

#pragma mark - New in this class.

+ (MCSharedBill *)addSharedBill
{
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
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
    return sharedBill;
}

+ (void)deleteSharedbill:(MCSharedBill *)deleteBill
{
    NSManagedObjectContext *context = [deleteBill managedObjectContext];
//    // Delete all paymentPresences of all payments.
//    for (MCPayment *payment in [deleteBill payments]) {
//        for (MCPaymentPresence *paymentPresence in [payment peopleSharingPayment]) {
//            [context deleteObject:paymentPresence];
//        }
//    }
//    // Delete all payments of the to be deleted sharedbill
//    for (MCPayment *payment in [deleteBill payments]) {
//        [context deleteObject:payment];
//    }
//    // Delete all emailaddresses of all people of the sharedbill.
//    for (MCPerson *person in [deleteBill peoplePresent]) {
//        for (MCEmailAddress *emailAddress in [person emailAddress]) {
//            [context deleteObject:emailAddress];
//        }
//    }
//    // Delete all people of the sharedbill.
//    for (MCPerson *person in [deleteBill peoplePresent]) {
//        [context deleteObject:person];
//    }
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
        return sharedBills[0];
    }
}

+ (BOOL)isTableInDatabaseEmpty
{
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
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
            return NO;
        }
    } else {
        return NO;
    }
}

- (NSString *)stringOfApproxPeoplePresent;
{
    NSArray *allPeople;
    NSArray *sda = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    allPeople = [[self peoplePresent] sortedArrayUsingDescriptors:sda];
    NSMutableString *returnString = [[NSMutableString alloc] init];
    if ([allPeople count] == 0) {
        return NSLocalizedString(@"NO_PEOPLE_PRESENT", @"A message when there are no people present inside this shared bill");
    } else if ([allPeople count] == 1) {
        return [allPeople[0] getName];
    } else if ([allPeople count] == 2) {
        NSString *enString = [NSString stringWithFormat:NSLocalizedString(@"AND_STRING", @"The word \"and\" between two people")];
        [returnString appendFormat:@"%@ %@ %@", [allPeople[0] getName], enString,[allPeople[1] getName]];
        return returnString;
    } else if ([allPeople count] >= 3) {
        NSString *andOthers = [NSString stringWithFormat:NSLocalizedString(@"AND_OTHERS", @"A list of people like Mark, Ilse and other where the \"and others\" needs to be translated.")];
        [returnString appendFormat:@"%@, %@ %@", [allPeople[0] getName], [allPeople[1] getName], andOthers];
        return returnString;
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
    return payment;
}

- (void)deletePayment:(MCPayment *)toBeDeletePayment
{
    // It is not allowed to delete a payment belonging to another sharedBill.
    NSParameterAssert([toBeDeletePayment onWhichBill] == self);
    
    // First delete the people presence on payment data.
    NSSet *paymentPresences = [toBeDeletePayment peopleSharingPayment];
    for (MCPaymentPresence *paymentPresence in paymentPresences) {
        [MCPaymentPresence deletePaymentPresence:paymentPresence];
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
        [MCPaymentPresence deletePaymentPresence:paymentPresence];
        [payment recalculateAveragePeopleOweAndStore];
    }
    [MCPerson deletePerson:toBeDeletedPerson];
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
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"uniquePersonId" ascending:YES];
    [request setSortDescriptors:@[sd]];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error = nil;
    NSArray *listOfPeopleWhoHavePaid = [context executeFetchRequest:request error:&error];
    if (!listOfPeopleWhoHavePaid) {
        NSLog(@"totalAmountOfPeopleWhoHavPaid fetch error: %@", [error localizedDescription]);
        return 0;
    } else {
        return [listOfPeopleWhoHavePaid count];
    }
}

- (NSNumber *)totalSumOfMoneyOfThisSharedBill
{
    double sumOfMoney = 0.0;
    for (MCPayment *p in [self payments]) {
        sumOfMoney += [[p money] doubleValue];
    }
    return @(sumOfMoney);
}

- (NSString *)totalSumOfMoneyOfThisSharedBillAsCurrencyString
{
    NSNumber *totalSpent = [self totalSumOfMoneyOfThisSharedBill];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setLocale:[NSLocale currentLocale]];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    return [nf stringFromNumber:totalSpent];
}

- (NSNumber *)totalSumPaidBy:(MCPerson *)person
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPayment"];
    [request setRelationshipKeyPathsForPrefetching:@[ @"payingPerson" ]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"onWhichBill = %@ AND payingPerson = %@", self, person]];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]]];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error = nil;
    NSArray *paymentsOfPerson = [context executeFetchRequest:request error:&error];
    if (!paymentsOfPerson) {
        NSLog(@"Error fetching paymentofPerson: %@", [error localizedDescription]);
    }
    double sumOfMoney = 0.0;
    for (MCPayment *p in paymentsOfPerson) {
        sumOfMoney += [[p money] doubleValue];
    }
    return @(sumOfMoney);
}

- (NSNumber *)totalAmountOfCreditBy:(MCPerson *)person
{
    double totalSumPaid = [[self totalSumPaidBy:person] doubleValue];
    double average = [[self amountPeopleShouldHavePaid] doubleValue];
    double credit = totalSumPaid - average;
    return @(credit);
}

- (BOOL)hasPersonPaidSomething:(MCPerson *)person
{
    NSNumber *paid = [self totalSumPaidBy:person];
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"payment.onWhichBill = %@ AND person = %@ AND isPersonPresent = %@", self, person, @YES];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"person" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];

    NSError *error;
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Something went wrong fetching sumOfAverageFromEachPayment: %@", error);
    }
    
    double sumOfAllOwes = 0;
    for (MCPaymentPresence *pp in results) {
        sumOfAllOwes += [[pp averageOweFromPayment] doubleValue];
    }
    
    return @(sumOfAllOwes);
}

- (NSString *)amountShouldHavePaidAsCurrencyStringBy:(MCPerson *)person
{
    // Still has no Unit test.
    NSNumber *shouldHavePaid = [self amountShouldHavePaidBy:person];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setLocale:[NSLocale currentLocale]];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    return [nf stringFromNumber:shouldHavePaid];
}


- (NSString *)amountPeopleShouldHavePaidAsCurrencyString
{
    NSNumber *averageSpentByPerson = [self amountPeopleShouldHavePaid];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setLocale:[NSLocale currentLocale]];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    return [nf stringFromNumber:averageSpentByPerson];
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
        NSLog(@"%@ paid %@", [person getName], [self totalSumPaidBy:person]);
        NSNumber *sumOfWhatWasPaidByPerson = [self totalSumPaidBy:person];
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
                MCReturnPayment *rp;
                if (ltp >= ltr) {
                    rp = [[MCReturnPayment alloc] initWithPayer:payer[0] paysTo:receiver[0] amountOfMoney:@(ltr)];
                    ltp -= ltr;
                    ltr = 0;
                } else {
                    rp = [[MCReturnPayment alloc] initWithPayer:payer[0] paysTo:receiver[0] amountOfMoney:@(ltp)];
                    ltr -= ltp;
                    ltp = 0;
                }
                leftToPay = @(ltp);
                leftToReceive = @(ltr);
                payer[3] = leftToPay;
                receiver[3] = leftToReceive;
                
                if ([[rp money] doubleValue] > 0) {
                    [whoHasToPayWho addObject:rp];
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

- (NSArray *)getArrayOfFullNamesOfPeoplePresent
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"getFullName" ascending:YES];
    return [[self peoplePresent] sortedArrayUsingDescriptors:@[sortDescriptor]];
}

#pragma mark - NSManagedObject Stuff

- (void)prepareForDeletion
{
    NSManagedObjectContext *context = [self managedObjectContext];
    // Delete all paymentPresences of all payments.
    for (MCPayment *payment in [self payments]) {
        for (MCPaymentPresence *paymentPresence in [payment peopleSharingPayment]) {
            [context deleteObject:paymentPresence];
        }
    }
    // Delete all payments of the to be deleted sharedbill
    for (MCPayment *payment in [self payments]) {
        [context deleteObject:payment];
    }
    // Delete all emailaddresses of all people of the sharedbill.
    for (MCPerson *person in [self peoplePresent]) {
        for (MCEmailAddress *emailAddress in [person emailAddress]) {
            [context deleteObject:emailAddress];
        }
    }
    // Delete all people of the sharedbill.
    for (MCPerson *person in [self peoplePresent]) {
        [context deleteObject:person];
    }
}

@end
