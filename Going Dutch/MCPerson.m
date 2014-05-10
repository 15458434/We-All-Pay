//
//  MCPerson.m
//  We all pay
//
//  Created by Mark Cornelisse on 07-05-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCPerson.h"
#import "MCEmailAddress.h"
#import "MCPayment.h"
#import "MCPaymentPresence.h"
#import "MCSharedBill.h"


@implementation MCPerson

@dynamic dateCreated;
@dynamic dateModified;
@dynamic defaultEmailAddress;
@dynamic firstName;
@dynamic getFullName;
@dynamic lastName;
@dynamic phoneNumber;
@dynamic picture;
@dynamic pictureData;
@dynamic thumbnail;
@dynamic thumbnailData;
@dynamic uniquePersonId;
@dynamic emailAddress;
@dynamic payments;
@dynamic sharedBill;
@dynamic sharingPayment;

@end
