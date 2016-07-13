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
    self.status = [NSNumber numberWithShort:MCExchangeRateStatusFetching];
    // If equal just set the exchangeRate to a value of 1.
    if ([self.fromCurrency isEqualToMCCurrency:self.toCurrency]) {
        self.exchangeRate = @(1);
        self.status = [NSNumber numberWithShort:MCExchangeRateStatusValid];
        completionHandler(nil);
        return;
    }
    ExchangeRateFetcher *fetcher = [[MCWeAllPayStoreController defaultStore] fetcher];
    __weak typeof(self) weakSelf = self;
    [fetcher exchangeRate:self.fromCurrency.code toCode:self.toCurrency.code completionHandler:^(NSString * fromCode, NSString * toCode, NSNumber * exchangeRate, NSError * error) {
        typeof(self) strongSelf = weakSelf;
        if (error) {
            completionHandler(error);
            if (strongSelf) {
                strongSelf.status = [NSNumber numberWithShort:MCExchangeRateStatusInvalid];
            }
            return;
        }
        if (strongSelf) {
            strongSelf.exchangeRate = exchangeRate;
            strongSelf.status = [NSNumber numberWithShort:MCExchangeRateStatusValid];
        }
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
