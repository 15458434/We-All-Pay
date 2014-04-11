//
//  MCSharedBill+addons.m
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"
#import "MCPayment+addons.h"
#import "MCWeAllPayStoreController.h"
#import "MCReturnPayment.h"

@implementation MCSharedBill (addons)

#pragma mark - New in this class.

+ (MCSharedBill *)addSharedBill
{
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
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
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    for (MCPayment *p in [deleteBill payments]) {
        [context deleteObject:p];
    }
    [context deleteObject:deleteBill];
}

+ (MCSharedBill *)fetchSharedBillWithUniqueId:(NSString *)uuid
{
    // Create a fetch request for MCSharedBills.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCSharedBill"];
    
    // Select only the sharedBill with uuid as uniqueBillId
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueBillId = %@", uuid];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *sharedBills = [[[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext] executeFetchRequest:request error:&error];
    if (!sharedBills) {
        // There was an error.
        return nil;
    } else {
        return sharedBills[0];
    }
}

+ (BOOL)isTableInDatabaseEmpty
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCSharedBill"];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES];
    NSArray *sda = @[sd];
    [request setSortDescriptors:sda];
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
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
    /*
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    NSArray *allPeople;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"any sharedBill = %@", self]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]]];
    NSError *error = nil;
    allPeople = [context executeFetchRequest:request error:&error];
    if (!allPeople) {
        NSLog(@"something went wrong fetching");
    }
     */
    
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
    MCPayment *payment = [MCPayment addPayment];
    [payment setOnWhichBill:self];
    return payment;
}

- (MCPerson *)addPerson
{
    MCPerson *newPerson = [MCPerson addPerson];
    [newPerson addSharedBillObject:self];
    return newPerson;
}

- (BOOL)isPresentWithFirstName:(NSString *)firstName andLastName:(NSString *)lastName andEmailAddress:(NSString *)emailAddress
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *sd2 = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    NSArray *sda = @[sd1, sd2];
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
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
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
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
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

- (NSString *)amountPeopleShouldHavePaidAsCurrencyString
{
    NSNumber *averageSpentByPerson = [self amountPeopleShouldHavePaid];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setLocale:[NSLocale currentLocale]];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    return [nf stringFromNumber:averageSpentByPerson];
}

- (NSArray *)solveWhoHasToPayWhoFromThisBill
{
    // Create two array's one of peope who should pay and one with people that should receive.
    NSMutableArray *payers = [[NSMutableArray alloc] init];
    NSNumber *leftToPay;
    NSNumber *leftToReceive;
    NSMutableArray *receivers = [[NSMutableArray alloc] init];
    NSMutableArray *whoHasToPayWho = [[NSMutableArray alloc] init];
    NSArray *sda1 = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    NSArray *people = [[self peoplePresent] sortedArrayUsingDescriptors:sda1];
    
    for (MCPerson *p in people) {
        NSLog(@"%@ paid %@", [p getName], [self totalSumPaidBy:p]);
    }
    
    for (MCPerson *p in people) {
        NSNumber *sumOfWhatWasPaidBy = [self totalSumPaidBy:p];
        NSNumber *sumOfWhatShouldBePaid = [self amountPeopleShouldHavePaid];
        
        if ([sumOfWhatWasPaidBy doubleValue] < [sumOfWhatShouldBePaid doubleValue]) {
            // This person should pay to someone.
            leftToPay = @([sumOfWhatShouldBePaid doubleValue] - [sumOfWhatWasPaidBy doubleValue]);
            NSArray *creditValueOfThisPerson = [[NSMutableArray alloc] initWithObjects:p, sumOfWhatShouldBePaid, sumOfWhatWasPaidBy, leftToPay, nil];
            [payers addObject:creditValueOfThisPerson];
        } else if ([sumOfWhatWasPaidBy doubleValue] > [sumOfWhatShouldBePaid doubleValue]){
            // This person should receive from someone.
            leftToReceive = @([sumOfWhatWasPaidBy doubleValue] - [sumOfWhatShouldBePaid doubleValue]);
            NSArray *creditValueOfThisPerson = [[NSMutableArray alloc] initWithObjects:p, sumOfWhatShouldBePaid, sumOfWhatWasPaidBy, leftToReceive, nil];
            [receivers addObject:creditValueOfThisPerson];
        } else {
            // This person has already paid enough.
            MCReturnPayment *notDepted = [[MCReturnPayment alloc] initWithPayer:p paysTo:nil amountOfMoney:@0.0];
            [whoHasToPayWho addObject:notDepted];
        }
    }
    
    // Solve who has to pay who.
    if ([payers count] > 0) {
        for (NSMutableArray *p in payers) {
            for (NSMutableArray *r in receivers) {
                double ltp = [p[3] doubleValue];
                double ltr = [r[3] doubleValue];
                MCReturnPayment *rp;
                if (ltp >= ltr) {
                    rp = [[MCReturnPayment alloc] initWithPayer:p[0] paysTo:r[0] amountOfMoney:@(ltr)];
                    ltp -= ltr;
                    ltr = 0;
                } else {
                    rp = [[MCReturnPayment alloc] initWithPayer:p[0] paysTo:r[0] amountOfMoney:@(ltp)];
                    ltr -= ltp;
                    ltp = 0;
                }
                leftToPay = @(ltp);
                leftToReceive = @(ltr);
                p[3] = leftToPay;
                r[3] = leftToReceive;
                
                if ([[rp money] doubleValue] > 0) {
                    [whoHasToPayWho addObject:rp];
                }
            }
        }
    } else {
    }
    return whoHasToPayWho;
}

- (NSArray *)getArrayOfFullNamesOfPeoplePresent
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"getFullName" ascending:YES];
    return [[self peoplePresent] sortedArrayUsingDescriptors:@[sortDescriptor]];
}

@end
