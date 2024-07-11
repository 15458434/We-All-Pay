//
//  MCExchangeRate.m
//  We all pay
//
//  Created by Mark Cornelisse on 01/08/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCExchangeRate.h"
#import "MCCurrency.h"
#import "MCPayment.h"


@implementation MCExchangeRate

#pragma mark - NSManagedObject

- (void)awakeFromInsert {
    [super awakeFromInsert];
    [self setPrimitiveValue:NSUUID.UUID.UUIDString forKey:@"uniqueID"];
    NSDate *now = NSDate.date;
    [self setPrimitiveValue:now forKey:@"dateCreated"];
    [self setPrimitiveValue:now forKey:@"dateModified"];
}

#pragma mark - NSObject

@end
