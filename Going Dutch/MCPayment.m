//
//  MCPayment.m
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPayment.h"
#import "MCPerson.h"
#import "MCSharedBill.h"


@implementation MCPayment

@dynamic dateCreated;
@dynamic dateModified;
@dynamic descriptionOfPayment;
@dynamic money;
@dynamic uniquePaymentId;
@dynamic onWhichBill;
@dynamic payingPerson;

@end
