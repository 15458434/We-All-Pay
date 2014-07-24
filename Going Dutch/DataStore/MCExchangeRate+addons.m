//
//  MCExchangeRate+addons.m
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCExchangeRate+addons.h"

@implementation MCExchangeRate (addons)

+ (MCExchangeRate *)addExchangeRateForContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"MCExchangeRate" inManagedObjectContext:context];
}

- (BOOL)retrieveExchangeRateFromWeb
{
    return NO;
}

#pragma mark - Inherited From Super

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    [self setPrimitiveValue:[[NSUUID UUID] UUIDString] forKey:@"uniqueID"];
    NSDate *now = [NSDate date];
    [self setPrimitiveValue:now forKey:@"dateCreated"];
    [self setPrimitiveValue:now forKey:@"dateModified"];
}



@end
