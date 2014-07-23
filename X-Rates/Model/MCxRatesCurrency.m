//
//  MCCurrency.m
//  We all pay
//
//  Created by Mark Cornelisse on 28-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCxRatesCurrency.h"

// NSCoding name strings.
NSString * const MCCodingCurrencyName = @"MCCodingCurrencyName";
NSString * const MCCodingCurrencySymbol = @"MCCodingCurrencySymbol";
NSString * const MCCodingCurrencyISOCode = @"MCCodingCurrencyISOCode";

@implementation MCxRatesCurrency

#pragma mark - Inherited from super

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[MCxRatesCurrency class]]) {
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

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setCurrencyISOCode:[aDecoder decodeObjectForKey:MCCodingCurrencyISOCode]];
        [self setCurrencyName:[aDecoder decodeObjectForKey:MCCodingCurrencyName]];
        [self setCurrencySymbol:[aDecoder decodeObjectForKey:MCCodingCurrencySymbol]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_currencyISOCode forKey:MCCodingCurrencyISOCode];
    [coder encodeObject:_currencyName forKey:MCCodingCurrencyName];
    [coder encodeObject:_currencySymbol forKey:MCCodingCurrencySymbol];
}

@end
