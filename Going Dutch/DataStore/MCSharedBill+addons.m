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
#import "MCTools.h"

@implementation MCSharedBill (addons)

#pragma mark - New in this class.

+ (MCSharedBill *)addSharedBill
{
    __block NSManagedObjectContext *context = [[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext];
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
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext];
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
    NSArray *sharedBills = [[[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext] executeFetchRequest:request error:&error];
    if (!sharedBills) {
        // There was an error.
        return nil;
    } else {
        return [sharedBills objectAtIndex:0];
    }
}

- (NSString *)stringOfApproxPeoplePresent;
{
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext];
    __block NSArray *allPeople;
    [context performBlockAndWait:^{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"all sharedBill = %@", self]];
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

- (NSNumber *)totalSumPaidBy:(MCPerson *)person
{
    // Just return the number 1000.
    NSLog(@"totSumPaidBy has not been implemented yet.");
    return [NSNumber numberWithDouble:1000.0];
}

- (BOOL)hasPersonPaidSomething:(MCPerson *)person
{
    NSLog(@"hasPersonPaidSomething is not implemented yet.");
    return NO;
}

@end
