//
//  MCExchangeRate+addons.m
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCExchangeRate+addons.h"
#import "MCWeAllPayStoreController.h"
#import "MCCurrency+addons.h"

#import "We_all_pay-Swift.h"

@implementation MCExchangeRate (addons)

+ (MCExchangeRate *)addExchangeRateForContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"MCExchangeRate" inManagedObjectContext:context];
}

- (void)fetchExchangeRate:(void (^)(NSError *))completionHandler
{
    NSParameterAssert(completionHandler);
    [self setStatus:[NSNumber numberWithShort:fetching]];
    ExchangeRateFetcher *fetcher = [[MCWeAllPayStoreController defaultStore] fetcher];
    [fetcher exchangeRate:self.fromCurrency.code toCode:self.toCurrency.code completionHandler:^(NSString * fromCode, NSString * toCode, NSNumber * exchangeRate, NSError * error) {
        if (error) {
            completionHandler(error);
            [self setStatus:[NSNumber numberWithShort:invalid]];
        }
        self.exchangeRate = exchangeRate;
        [self setStatus:[NSNumber numberWithShort:valid]];
        completionHandler(nil);
    }];
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
