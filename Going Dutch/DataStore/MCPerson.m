//
//  MCPerson.m
//  We all pay
//
//  Created by Mark Cornelisse on 12-07-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPerson.h"

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

@synthesize edgeRadius;

#pragma mark - Inherited From Super

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    edgeRadius = [NSNumber numberWithDouble:5.0];
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    edgeRadius = [NSNumber numberWithDouble:5.0];
}

@end
