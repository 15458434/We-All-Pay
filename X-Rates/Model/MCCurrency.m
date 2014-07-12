//
//  MCCurrency.m
//  We all pay
//
//  Created by Mark Cornelisse on 28-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCCurrency.h"

@implementation MCCurrency

#pragma mark - Inherited from super

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[MCCurrency class]]) {
        return NO;
    }
    
    if (![_currencyISOCode isEqualToString:[object currencyISOCode]]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash
{
    return [_currencyISOCode hash];
}

@end
