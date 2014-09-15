//
//  MCColors.m
//  We all pay
//
//  Created by Mark Cornelisse on 24-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCColors.h"

@implementation MCColors

+ (UIColor *)getbackgroundColor
{
    return [MCTools colorWith8BitRed:213 green:236 blue:253 alpha:1.0];
}

+ (UIColor *)getButtonColor
{
    return [MCTools colorWith8BitRed:255 green:135 blue:173 alpha:1.0];
}

+ (UIColor *)getButtonDisabledColor
{
    return [MCTools colorWith8BitRed:255 green:222 blue:228 alpha:1.0];
}

+ (UIColor *)getNavigationColor
{
    return [MCTools colorWith8BitRed:0 green:51 blue:102 alpha:1.0];
}

+ (UIColor *)getEmptyMessageTextColor
{
    return [MCTools colorWith8BitRed:120 green:165 blue:193 alpha:1.0];
}

@end
