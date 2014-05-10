//
//  MCPayment+addons.m
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPayment+addons.h"
#import "MCPerson.h"
#import "MCSharedBill.h"
#import "MCPaymentPresence+addons.h"
#import "MCWeAllPayStoreController.h"

@implementation MCPayment (addons)

+ (MCPayment *)addPayment
{
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
     MCPayment *newPayment;
    newPayment = [NSEntityDescription insertNewObjectForEntityForName:@"MCPayment" inManagedObjectContext:context];
    [newPayment setUniquePaymentId:[MCTools createUniqueIdentifierString]];
    [newPayment setDateCreated:[NSDate date]];
    [newPayment setDateModified:[newPayment dateCreated]];
    return newPayment;
}

+ (void)deletePayment:(MCPayment *)payment
{
    // Wat te doen met mogelijke sharedBills en personen die aanwezig zijn?
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context deleteObject:payment];
}

+ (MCPayment *)fetchPaymentWithUniqueId:(NSString *)uuid
{
    // Create a fetch request for MCSharedBills.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPayment"];
    
    // Select only the sharedBill with uuid as uniqueBillId
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniquePaymentId = %@", uuid];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *payments = [[[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext] executeFetchRequest:request error:&error];
    if (!payments) {
        // There was an error.
        return nil;
    } else {
        return payments[0];
    }
}

+ (BOOL)isTableInDatabaseEmpty
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPayment"];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"money" ascending:YES];
    NSArray *sda = @[sd];
    [request setSortDescriptors:sda];
    NSError *error;
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    NSArray *allPayments = [context executeFetchRequest:request error:&error];
    if (allPayments) {
        if ([allPayments count] == 0) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (BOOL)hasPayer
{
    if ([self payingPerson]) {
        return YES;
    } else {
        return NO;
    }
}

- (MCPaymentPresence *)fetchPaymentPresenceForPerson:(MCPerson *)person
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPaymentPresence"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"payment = %@ AND person = %@", self, person];
    [request setPredicate:predicate];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"averageOweFromPayment" ascending:YES];
    [request setSortDescriptors:@[sd]];
    
    NSError *error;
    NSArray *fetchResults = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Something went wrong fetching MCPaymentPresence: %@", [error localizedDescription]);
    }
    return [fetchResults objectAtIndex:0];
}

- (void)thisPerson:(MCPerson *)person setIsPresent:(NSNumber *)isPresent
{
    MCPaymentPresence *thisPersonsPresence = [self fetchPaymentPresenceForPerson:person];
    [[MCWeAllPayStoreController defaultStore] beginUndoGroupWithoutRegistration];
    [thisPersonsPresence setIsPersonPresent:isPresent];
    [self recalculateAveragePeopleOweAndStore];
    [[MCWeAllPayStoreController defaultStore] endUndoGroupWithoutRegistration];
}

- (NSNumber *)peoplePresentOnThisPayment
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPaymentPresence"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"payment = %@ AND isPersonPresent = %@", self, @YES];
    [request setPredicate:predicate];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"averageOweFromPayment" ascending:YES];
    [request setSortDescriptors:@[sd]];
    NSError *error;
    NSUInteger *countInteger = [[self managedObjectContext] countForFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Something went wrong counting people present: %@", [error localizedDescription]);
    }
    return [NSNumber numberWithUnsignedInteger:countInteger];
}

- (NSNumber *)averageAmountPeopleShouldHavePaidOnThisPayment
{
    double peoplePresentOnThisPayment = [[self peoplePresentOnThisPayment] doubleValue];
    double result = [[self money] doubleValue] / peoplePresentOnThisPayment;
    return [NSNumber numberWithDouble:result];
}

- (void)recalculateAveragePeopleOweAndStore
{
    NSNumber *averagePayedByPeoplePresent = [self averageAmountPeopleShouldHavePaidOnThisPayment];
    for (MCPaymentPresence *pp in [self peopleSharingPayment]) {
        if ([[pp isPersonPresent] boolValue]) {
            [pp setAverageOweFromPayment:averagePayedByPeoplePresent];
        } else {
            [pp setAverageOweFromPayment:@0.00];
        }
    }
}

- (NSString *)getMoneyValueAsAString
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    [nf setLocale:[NSLocale currentLocale]];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    return [nf stringFromNumber:[self money]];
}

- (NSString *)getMoneyValueInCurrencyAsAString
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setLocale:[NSLocale currentLocale]];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    return [nf stringFromNumber:[self money]];
}

- (void)putMoneyValueAsAString:(NSString *)moneyString
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setLocale:[NSLocale currentLocale]];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    [[MCWeAllPayStoreController defaultStore] beginUndoGroupWithoutRegistration];
    [self setMoney:[nf numberFromString:moneyString]];
    [self recalculateAveragePeopleOweAndStore];
    [[MCWeAllPayStoreController defaultStore] endUndoGroupWithoutRegistration];
}

- (void)putMoneyValueInCurrencyAsAString:(NSString *)moneyString
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setLocale:[NSLocale currentLocale]];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    
    [[MCWeAllPayStoreController defaultStore] beginUndoGroupWithoutRegistration];
    [self setMoney:[nf numberFromString:moneyString]];
    [self recalculateAveragePeopleOweAndStore];
    [[MCWeAllPayStoreController defaultStore] endUndoGroupWithoutRegistration];
}

@end
