//
//  MCPayment.m
//  We all pay
//
//  Created by Mark Cornelisse on 10-07-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPayment.h"
#import "MCPerson.h"
#import "MCSharedBill.h"
#import "MCWeAllPayStoreController.h"
#import "MCTools.h"

@implementation MCPayment

@dynamic descriptionOfPayment;
@dynamic money;
@dynamic dateCreated;
@dynamic uniquePaymentId;
@dynamic dateModified;
@dynamic onWhichBill;
@dynamic payingPerson;

+ (MCPayment *)addPayment
{
    MCPayment *newPayment = [NSEntityDescription insertNewObjectForEntityForName:@"MCPayment" inManagedObjectContext:[[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext]];
    [newPayment setUniquePaymentId:[MCTools createUniqueIdentifierString]];
    return newPayment;
}

+ (void)deletePayment:(MCPayment *)payment
{
    // Wat te doen met mogelijke sharedBills en personen die aanwezig zijn?
    [[[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext] deleteObject:payment];
}

+ (MCPayment *)fetchPaymentWithUniqueId:(NSString *)uuid
{
    // Create a fetch request for MCSharedBills.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPayment"];
    
    // Select only the sharedBill with uuid as uniqueBillId
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniquePaymentId = %@", uuid];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *payments = [[[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext] executeFetchRequest:request error:&error];
    if (!payments) {
        // There was an error.
        return nil;
    } else {
        return [payments objectAtIndex:0];
    }
}

@end
