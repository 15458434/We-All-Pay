//
//  MCEmailAddress+addons.m
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCEmailAddress+addons.h"
#import "MCPerson+addons.h"
#import "MCWeAllPayStoreController.h"

@implementation MCEmailAddress (addons)

+ (MCEmailAddress *)addEmailAddressFor:(MCPerson *)person
{
    __block MCEmailAddress *newEmailAddress;
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlockAndWait:^{
        newEmailAddress = [NSEntityDescription insertNewObjectForEntityForName:@"MCEmailAddress" inManagedObjectContext:context];
        [newEmailAddress setUniqueEmailId:[MCTools createUniqueIdentifierString]];
        [newEmailAddress setOwner:person];
    }];
    return newEmailAddress;
}

+ (void)deleteEmailAddress:(MCEmailAddress *)eAddress
{
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlockAndWait:^{
        [context deleteObject:eAddress];
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

+ (MCEmailAddress *)fetchEmailAddressFor:(MCPerson *)person
{
    // Create a fetch request for MCEmailAddress
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCEmailAddress"];
    
    // Select only emailAddresses for person
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"owner = %@", person];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"selected = %@", [NSNumber numberWithBool:YES]];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate1, predicate2, nil]];
    [request setPredicate:compoundPredicate];
    
    NSError *error;
    NSArray *emailAddresses;
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    emailAddresses = [context executeFetchRequest:request error:&error];
    if (!emailAddresses) {
        NSLog(@"There was error fetching email addresses for %@", [person getFullName]);
        return nil;
    } else {
        if ([emailAddresses count] == 0) {
            return nil;
        } else {
            return [emailAddresses objectAtIndex:0];
        }
    }
}

@end
