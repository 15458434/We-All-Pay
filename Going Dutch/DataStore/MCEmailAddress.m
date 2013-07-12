//
//  MCEmailAddress.m
//  We all pay
//
//  Created by Mark Cornelisse on 12-07-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCEmailAddress.h"
#import "MCPerson.h"
#import "MCWeAllPayStoreController.h"

#import "MCTools.h"

@implementation MCEmailAddress

@dynamic uniqueEmailId;
@dynamic emailAddress;
@dynamic selected;
@dynamic owner;

+ (MCEmailAddress *)addEmailAddressFor:(MCPerson *)person
{
    MCEmailAddress *newEmailAddress = [NSEntityDescription insertNewObjectForEntityForName:@"MCEmailAddress" inManagedObjectContext:[[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext]];
    [newEmailAddress setUniqueEmailId:[MCTools createUniqueIdentifierString]];
    [newEmailAddress setOwner:person];
    
    return newEmailAddress;
}

+ (void)deleteEmailAddress:(MCEmailAddress *)eAddress
{
    [[[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument ] managedObjectContext] deleteObject:eAddress];
}

@end
