//
//  SKProduct+MCStoreInterface.m
//  We all pay
//
//  Created by Mark Cornelisse on 16-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "SKProduct+MCStoreInterface.h"

@implementation SKProduct (MCStoreInterface)

- (NSString *)priceString
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:[self priceLocale]];
    return [numberFormatter stringFromNumber:[self price]];
}

@end
