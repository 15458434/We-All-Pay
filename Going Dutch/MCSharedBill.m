//
//  MCSharedBill.m
//  We all pay
//
//  Created by Mark Cornelisse on 22/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBill.h"
#import "MCCurrency.h"
#import "MCPayment.h"
#import "MCPerson.h"


@implementation MCSharedBill

@dynamic dateCreated;
@dynamic dateModified;
@dynamic hasTheMailBeenSent;
@dynamic tripName;
@dynamic uniqueBillId;
@dynamic payments;
@dynamic peoplePresent;
@dynamic mainCurrency;

@end
