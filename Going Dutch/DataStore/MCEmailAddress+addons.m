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
    MCEmailAddress *newEmailAddress;
    NSManagedObjectContext *context = [person managedObjectContext];
    newEmailAddress = [NSEntityDescription insertNewObjectForEntityForName:@"MCEmailAddress" inManagedObjectContext:context];
    [newEmailAddress setUniqueEmailId:[[NSUUID UUID] UUIDString] ];
    [newEmailAddress setOwner:person];
    NSDate *nu = [NSDate date];
    [newEmailAddress setDateCreated:nu];
    [newEmailAddress setDateModified:nu];
    return newEmailAddress;
}

+ (void)deleteEmailAddress:(MCEmailAddress *)eAddress
{
    NSManagedObjectContext *context = [eAddress managedObjectContext];
    MCPerson *owner = [eAddress owner];
    [eAddress setOwner:nil];
    [context deleteObject:eAddress];
    [context refreshObject:owner mergeChanges:YES];
}

+ (MCEmailAddress *)fetchEmailAddressWithUniqueId:(NSString *)uuid
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
        return sharedBills[0];
    }
}

+ (BOOL)isTableInDatabaseEmpty
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCEmailAddress"];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"emailAddress" ascending:YES];
    NSArray *sda = @[sd];
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

+ (MCEmailAddress *)fetchEmailAddressFor:(MCPerson *)person
{
    // Create a fetch request for MCEmailAddress
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCEmailAddress"];
    
    // Select only emailAddresses for person
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"owner = %@", person];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"selected = %@", @YES];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1, predicate2]];
    [request setPredicate:compoundPredicate];
    
    NSError *error;
    NSArray *emailAddresses;
//    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    emailAddresses = [[person managedObjectContext] executeFetchRequest:request error:&error];
    if (!emailAddresses) {
        NSLog(@"There was error fetching email addresses for %@", [person getFullName]);
        return nil;
    } else {
        if ([emailAddresses count] == 0) {
            return nil;
        } else {
            return emailAddresses[0];
        }
    }
}

@end
