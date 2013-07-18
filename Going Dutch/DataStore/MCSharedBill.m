//
//  MCSharedBill.m
//  We all pay
//
//  Created by Mark Cornelisse on 10-07-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBill.h"
#import "MCPerson.h"
#import "MCPayment.h"
#import "MCWeAllPayStoreController.h"
#import "MCTools.h"

@implementation MCSharedBill

@dynamic dateCreated;
@dynamic dateModified;
@dynamic hasTheMailBeenSent;
@dynamic tripName;
@dynamic uniqueBillId;
@dynamic payments;
@dynamic peoplePresent;

#pragma mark - New in this class.

+ (MCSharedBill *)addSharedBill
{
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext];
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

- (NSString *)stringOfApproxPeoplePresent
{
    return @"Test string of Approx People Present";
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
    return [NSNumber numberWithDouble:1000.0];
}

- (BOOL)hasPersonPaidSomething:(MCPerson *)person
{
    return NO;
}

@end
