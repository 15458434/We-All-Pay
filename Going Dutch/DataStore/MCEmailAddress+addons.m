//
//  MCEmailAddress+addons.m
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCEmailAddress+addons.h"
#import "MCPerson+addons.h"

@implementation MCEmailAddress (addons)

+ (MCEmailAddress *)addEmailAddressFor:(MCPerson *)person {
    MCEmailAddress *newEmailAddress = [NSEntityDescription insertNewObjectForEntityForName:@"MCEmailAddress" inManagedObjectContext:person.managedObjectContext];
    newEmailAddress.uniqueEmailId = [[NSUUID UUID] UUIDString];
    
    newEmailAddress.owner = person;
    [person addEmailAddressObject:newEmailAddress];
    
    NSDate *nu = [NSDate date];
    newEmailAddress.dateCreated = nu;
    newEmailAddress.dateModified = nu;
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

+ (MCEmailAddress *)fetchEmailAddressFor:(MCPerson *)person
{
    // Create a fetch request for MCEmailAddress
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCEmailAddress"];
    
    // Select only emailAddresses for person
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"owner = %@", person];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"selected = %@", @YES];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate1, predicate2]];
    request.predicate = compoundPredicate;
    NSError *error;
    NSArray *emailAddresses;
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
