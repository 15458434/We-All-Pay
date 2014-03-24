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
        return [payments objectAtIndex:0];
    }
}

+ (BOOL)isTableInDatabaseEmpty
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPayment"];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"money" ascending:YES];
    NSArray *sda = [NSArray arrayWithObject:sd];
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

@end
