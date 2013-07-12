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
    MCSharedBill *sharedBill = [NSEntityDescription insertNewObjectForEntityForName:@"MCSharedBill" inManagedObjectContext:[[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext]];
    [sharedBill setUniqueBillId:[MCTools createUniqueIdentifierString]];
    [sharedBill setHasTheMailBeenSent:[NSNumber numberWithBool:NO]];
    NSDate *nu = [NSDate date];
    [sharedBill setDateCreated:nu];
    [sharedBill setDateModified:nu];
    return sharedBill;
}

+ (void)deleteSharedbill:(MCSharedBill *)deleteBill
{
    // Wat te doen met mogelijke payments en personen die aanwezig zijn?
    [[[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext] deleteObject:deleteBill];
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

@end
