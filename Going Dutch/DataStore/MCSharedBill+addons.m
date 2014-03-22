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
    [sharedBill setHasTheMailBeenSent:[NSNumber numberWithBool:NO]];
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
        return [sharedBills objectAtIndex:0];
    }
}

+ (BOOL)isTableInDatabaseEmpty
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCSharedBill"];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES];
    NSArray *sda = [NSArray arrayWithObjects:sd, nil];
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

+ (MCSharedBill *)fetchSharedBillWithUniqueId:(NSString *)uuid fromContext:(NSManagedObjectContext *)context
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
        return [sharedBills objectAtIndex:0];
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
    NSArray *sda = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    allPeople = [[self peoplePresent] sortedArrayUsingDescriptors:sda];
    NSMutableString *returnString = [[NSMutableString alloc] init];
    if ([allPeople count] == 0) {
        return NSLocalizedString(@"NO_PEOPLE_PRESENT", @"A message when there are no people present inside this shared bill");
    } else if ([allPeople count] == 1) {
        return [[allPeople objectAtIndex:0] getName];
    } else if ([allPeople count] == 2) {
        NSString *enString = [NSString stringWithFormat:NSLocalizedString(@"AND_STRING", @"The word \"and\" between two people")];
        [returnString appendFormat:@"%@ %@ %@", [[allPeople objectAtIndex:0] getName], enString,[[allPeople objectAtIndex:1] getName]];
        return returnString;
    } else if ([allPeople count] >= 3) {
        NSString *andOthers = [NSString stringWithFormat:NSLocalizedString(@"AND_OTHERS", @"A list of people like Mark, Ilse and other where the \"and others\" needs to be translated.")];
        [returnString appendFormat:@"%@, %@ %@", [[allPeople objectAtIndex:0] getName], [[allPeople objectAtIndex:1] getName], andOthers];
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
    [request setSortDescriptors:[NSArray arrayWithObject:sd]];
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
    return [NSNumber numberWithDouble:sumOfMoney];
}

- (NSNumber *)totalSumPaidBy:(MCPerson *)person
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPayment"];
    [request setRelationshipKeyPathsForPrefetching:@[ @"payingPerson" ]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"onWhichBill = %@ AND payingPerson = %@", self, person]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]]];
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
    return [NSNumber numberWithDouble:sumOfMoney];
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
        return [NSNumber numberWithDouble:average];
    } else {
        return [NSNumber numberWithDouble:0.0];
    }
}

- (NSArray *)solveWhoHasToPayWhoFromThisBill
{
    // Create two array's one of peope who should pay and one with people that should receive.
    NSMutableArray *payers = [[NSMutableArray alloc] init];
    NSNumber *leftToPay;
    NSNumber *leftToReceive;
    NSMutableArray *receivers = [[NSMutableArray alloc] init];
    NSMutableArray *whoHasToPayWho = [[NSMutableArray alloc] init];
    NSArray *sda1 = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    NSArray *people = [[self peoplePresent] sortedArrayUsingDescriptors:sda1];
    
    for (MCPerson *p in people) {
        NSLog(@"%@ paid %@", [p getName], [self totalSumPaidBy:p]);
    }
    
    for (MCPerson *p in people) {
        NSNumber *sumOfWhatWasPaidBy = [self totalSumPaidBy:p];
        NSNumber *sumOfWhatShouldBePaid = [self amountPeopleShouldHavePaid];
        
        if ([sumOfWhatWasPaidBy doubleValue] < [sumOfWhatShouldBePaid doubleValue]) {
            // This person should pay to someone.
            leftToPay = [[NSNumber alloc] initWithDouble:[sumOfWhatShouldBePaid doubleValue] - [sumOfWhatWasPaidBy doubleValue]];
            NSArray *creditValueOfThisPerson = [[NSMutableArray alloc] initWithObjects:p, sumOfWhatShouldBePaid, sumOfWhatWasPaidBy, leftToPay, nil];
            [payers addObject:creditValueOfThisPerson];
        } else if ([sumOfWhatWasPaidBy doubleValue] > [sumOfWhatShouldBePaid doubleValue]){
            // This person should receive from someone.
            leftToReceive = [[NSNumber alloc] initWithDouble:[sumOfWhatWasPaidBy doubleValue] - [sumOfWhatShouldBePaid doubleValue]];
            NSArray *creditValueOfThisPerson = [[NSMutableArray alloc] initWithObjects:p, sumOfWhatShouldBePaid, sumOfWhatWasPaidBy, leftToReceive, nil];
            [receivers addObject:creditValueOfThisPerson];
        } else {
            // This person has already paid enough.
            MCReturnPayment *notDepted = [[MCReturnPayment alloc] initWithPayer:p paysTo:nil amountOfMoney:[NSNumber numberWithDouble:0.0]];
            [whoHasToPayWho addObject:notDepted];
        }
    }
    
    // Solve who has to pay who.
    if ([payers count] > 0) {
        for (NSMutableArray *p in payers) {
            for (NSMutableArray *r in receivers) {
                double ltp = [[p objectAtIndex:3] doubleValue];
                double ltr = [[r objectAtIndex:3] doubleValue];
                MCReturnPayment *rp;
                if (ltp >= ltr) {
                    rp = [[MCReturnPayment alloc] initWithPayer:[p objectAtIndex:0] paysTo:[r objectAtIndex:0] amountOfMoney:[NSNumber numberWithDouble:ltr]];
                    ltp -= ltr;
                    ltr = 0;
                } else {
                    rp = [[MCReturnPayment alloc] initWithPayer:[p objectAtIndex:0] paysTo:[r objectAtIndex:0] amountOfMoney:[NSNumber numberWithDouble:ltp]];
                    ltr -= ltp;
                    ltp = 0;
                }
                leftToPay = [[NSNumber alloc] initWithDouble:ltp];
                leftToReceive = [[NSNumber alloc] initWithDouble:ltr];
                [p replaceObjectAtIndex:3 withObject:leftToPay];
                [r replaceObjectAtIndex:3 withObject:leftToReceive];
                
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
    return [[self peoplePresent] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (MCSharedBill *)getTonightsBillFromParentContext
{
    NSLog(@"getTonightsBillFromParentContext is not working.");
    __block MCSharedBill *tonightsBillFromParentContext;
    NSString *uuidCopy = [[self uniqueBillId] copy];
    NSManagedObjectContext *parentContext = [self managedObjectContext];
    [parentContext performBlockAndWait:^{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCSharedBill"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"uniqueBillId = %@", uuidCopy]];
        [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"uniqueBillId" ascending:YES]]];
        NSError *error = nil;
        NSArray *fetchedBills = [parentContext executeFetchRequest:request error:&error];
        if (!fetchedBills) {
            NSLog(@"Error fetching tonightsBill from parentContext: %@", [error localizedDescription]);
        } else {
            tonightsBillFromParentContext = [fetchedBills objectAtIndex:0];
        }
    }];
    return tonightsBillFromParentContext;
}

@end
