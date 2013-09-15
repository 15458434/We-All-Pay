//
//  MCSharedBill+addons.m
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"
#import "MCPayment.h"
#import "MCWeAllPayStoreController.h"
#import "MCReturnPayment.h"

@implementation MCSharedBill (addons)

#pragma mark - New in this class.

+ (MCSharedBill *)addSharedBill
{
    __block NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    __block MCSharedBill *sharedBill;
    [context performBlockAndWait:^{
        sharedBill = [NSEntityDescription insertNewObjectForEntityForName:@"MCSharedBill" inManagedObjectContext:context];
        [sharedBill setUniqueBillId:[MCTools createUniqueIdentifierString]];
        [sharedBill setHasTheMailBeenSent:[NSNumber numberWithBool:NO]];
        NSDate *nu = [NSDate date];
        [sharedBill setDateCreated:nu];
        [sharedBill setDateModified:nu];
    }];
    return sharedBill;
}

+ (void)deleteSharedbill:(MCSharedBill *)deleteBill
{
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlock:^{
        [context deleteObject:deleteBill];
    }];
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

- (NSString *)stringOfApproxPeoplePresent;
{
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    __block NSArray *allPeople;
    [context performBlockAndWait:^{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"any sharedBill = %@", self]];
        [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]]];
        NSError *error = nil;
        allPeople = [context executeFetchRequest:request error:&error];
        if (!allPeople) {
            NSLog(@"something went wrong fetching");
        }
    }];
    
    NSMutableString *returnString = [[NSMutableString alloc] init];
    if ([allPeople count] == 0) {
        return @"No people present.";
    } else if ([allPeople count] == 1) {
            return [[allPeople objectAtIndex:0] getName];
    } else if ([allPeople count] == 2) {
            [returnString appendFormat:@"%@ and %@", [[allPeople objectAtIndex:0] getName], [[allPeople objectAtIndex:1] getName]];
            return returnString;
    } else if ([allPeople count] >= 3) {
            [returnString appendFormat:@"%@, %@ and others", [[allPeople objectAtIndex:0] getName], [[allPeople objectAtIndex:1] getName]];
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
    NSLog(@"totalAmountOfPeoplewWhoHavePaid is not implemented yet.");
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
    //request.predicate = [NSPredicate predicateWithFormat:@"sharedBill = %@ AND payments.onWhichBill = %@", self, self];
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

-(NSNumber *)totalSumOfMoneyOfThisSharedBill
{
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    __block NSArray *payments = nil;
    [context performBlockAndWait:^{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPayment"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"onWhichBill = %@", self]];
        [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO]]];
        NSError *error = nil;
        payments = [context executeFetchRequest:request error:&error];
        if (!payments) {
            NSLog(@"Error fetching payments on this bill");
        }
    }];
    double sumOfMoney = 0.0;
    for (MCPayment *p in payments) {
        sumOfMoney += [[p money] doubleValue];
    }
    return [NSNumber numberWithDouble:sumOfMoney];
}

- (NSNumber *)totalSumPaidBy:(MCPerson *)person
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPayment"];
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
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    NSArray *people = [self.peoplePresent sortedArrayUsingDescriptors:sortDescriptors];
    for (MCPerson *person in people) {
        if (![person isThereAnEmailAddress]) {
            return NO;
        }
    }
    return YES;
}

- (NSNumber *)amountPeopleShouldHavePaid
{
    double sumOfMoney = [[self totalSumOfMoneyOfThisSharedBill] doubleValue];
    double average = sumOfMoney / [[self peoplePresent] count];
    return [NSNumber numberWithDouble:average];
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
        NSLog(@"%@", [self totalSumPaidBy:p]);
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
            
            if ([rp money] > 0) {
                [whoHasToPayWho addObject:rp];
            }
        }
    }
    return whoHasToPayWho;

}

@end
