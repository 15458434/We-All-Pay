//
//  MCPerson.m
//  We all pay
//
//  Created by Mark Cornelisse on 12-07-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPerson.h"
#import "MCPayment.h"
#import "MCSharedBill.h"
#import "MCWeAllPayStoreController.h"

#import "MCTools.h"


@implementation MCPerson

@dynamic dateCreated;
@dynamic dateModified;
@dynamic defaultEmailAddress;
@dynamic firstName;
@dynamic lastName;
@dynamic phoneNumber;
@dynamic picture;
@dynamic pictureData;
@dynamic thumbnail;
@dynamic thumbnailData;
@dynamic uniquePersonId;
@dynamic payments;
@dynamic sharedBill;
@dynamic emailAddress;

+ (MCPerson *)addPerson
{
    MCPerson *newPerson = [NSEntityDescription insertNewObjectForEntityForName:@"MCPerson" inManagedObjectContext:[[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext]];
    [newPerson setUniquePersonId:[MCTools createUniqueIdentifierString]];
    NSDate *nu = [NSDate date];
    [newPerson setDateCreated:nu];
    [newPerson setDateModified:nu];
    return newPerson;
}

@end
