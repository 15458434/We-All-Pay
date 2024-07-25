//
//  MCPayment.m
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCPayment.h"
#import "MCCurrency.h"
#import "MCExchangeRate+CoreDataProperties.h"
#import "MCPaymentPresence.h"
#import "MCPerson.h"
#import "MCSharedBill.h"
#import "MCCurrency+CoreDataProperties.h"
#import "MCPayment+CoreDataProperties.h"


@implementation MCPayment

#pragma mark - NSManagedObject

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    [self setPrimitiveValue:NSUUID.UUID.UUIDString forKey:@"uniquePaymentId"];
    NSDate *now = NSDate.date;
    [self setPrimitiveValue:now forKey:@"dateCreated"];
    [self setPrimitiveValue:now forKey:@"dateModified"];
}

#pragma mark - NSObject

@end
