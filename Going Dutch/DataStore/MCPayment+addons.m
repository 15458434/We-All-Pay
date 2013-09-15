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
    __block MCPayment *newPayment;
    [context performBlockAndWait:^{
        newPayment = [NSEntityDescription insertNewObjectForEntityForName:@"MCPayment" inManagedObjectContext:[[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext]];
        
        [newPayment setUniquePaymentId:[MCTools createUniqueIdentifierString]];
        [newPayment setDateCreated:[NSDate date]];
        [newPayment setDateModified:[newPayment dateCreated]];
    }];
    return newPayment;
}

+ (void)deletePayment:(MCPayment *)payment
{
    // Wat te doen met mogelijke sharedBills en personen die aanwezig zijn?
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlock:^{
        [context deleteObject:payment];
    }];
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

@end
