//
//  MCCurrency.m
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCCurrency.h"
#import "MCExchangeRate.h"
#import "MCPayment.h"
#import "MCSharedBill.h"

@implementation MCCurrency

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
