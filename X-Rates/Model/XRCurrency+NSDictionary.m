//
//  XRCurrency+NSDictionary.m
//  We all pay
//
//  Created by Mark Cornelisse on 13/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

#import "XRCurrency+NSDictionary.h"

@implementation XRCurrency (NSDictionary)

- (NSDictionary *)convertToDictionary
{
    NSString *code = [self code];
    NSString *name = [self name];
    return @{@"code": code,
             @"name": name};
}

@end
