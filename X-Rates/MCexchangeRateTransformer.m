//
//  MCexchangeRateTransformer.m
//  We all pay
//
//  Created by Mark Cornelisse on 28-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCexchangeRateTransformer.h"

@implementation MCexchangeRateTransformer

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    double originalValue;
    if (value == nil) return nil;
    // Attempt to get a reasonable value from the
    // value object.
    if ([value respondsToSelector: @selector(doubleValue)]) {
        originalValue = [value doubleValue];
    } else {
        [NSException raise: NSInternalInconsistencyException
                    format: @"Value (%@) does not respond to -doubleValue.", [value class]];
    }
    return @(originalValue * [_exchangeRateValue doubleValue]);
}

- (id)reverseTransformedValue:(id)value
{
    NSLog(@"What is this for.");
    return nil;
}

@end
