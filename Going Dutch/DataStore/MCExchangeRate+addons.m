//
//  MCExchangeRate+addons.m
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCExchangeRate+addons.h"
#import "MCxRatesController.h"
#import "MCWeAllPayStoreController.h"
#import "MCCurrency+addons.h"

@implementation MCExchangeRate (addons)

+ (MCExchangeRate *)addExchangeRateForContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"MCExchangeRate" inManagedObjectContext:context];
}

- (BOOL)retrieveExchangeRateFromWeb
{
    MCExchangeRateStatus fetchingStatus = fetching;
    [self setStatus:[NSNumber numberWithShort:fetchingStatus]];
    NSLog(@"MCExchangeRate Status is fetching.");
    [[MCWeAllPayStoreController defaultStore] updateXRate:self withCompletionHandler:^(NSDictionary *exchangeRateResult) {
        MCExchangeRateStatus exchangeRateFetchStatus = valid;
        [self setStatus:[NSNumber numberWithShort:exchangeRateFetchStatus]];
        NSLog(@"MCExchangeRate Status is valid.");
    }];
    return YES;
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
