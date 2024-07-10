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

+ (void)deleteEmailAddress:(MCEmailAddress *)eAddress {
    NSManagedObjectContext *context = [eAddress managedObjectContext];
    MCPerson *owner = [eAddress owner];
    [eAddress setOwner:nil];
    [context deleteObject:eAddress];
    [context refreshObject:owner mergeChanges:YES];
}

@end
