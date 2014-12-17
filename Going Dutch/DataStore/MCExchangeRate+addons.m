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
    __weak typeof(self) weakSelf = self;
    return [self retrieveExchangeRateFromWebWithCompletionHandler:^(NSDictionary *exchangeRateResult) {
        if (!exchangeRateResult) {
            NSLog(@"%@ something went wrong fetching exchangeRate.", weakSelf);
        }
    }];
}

- (BOOL)retrieveExchangeRateFromWebWithCompletionHandler:(void (^)(NSDictionary *))completionBlock
{
    MCExchangeRateStatus fetchingStatus = fetching;
    [self setStatus:[NSNumber numberWithShort:fetchingStatus]];
    NSLog(@"MCExchangeRate Status is fetching.");
    [[MCWeAllPayStoreController defaultStore] updateXRate:self withCompletionHandler:^(NSDictionary *exchangeRateResult) {
        if (exchangeRateResult) {
            MCExchangeRateStatus exchangeRateFetchStatus = valid;
            [self setStatus:[NSNumber numberWithShort:exchangeRateFetchStatus]];
            NSLog(@"MCExchangeRate Status is valid.");
            if (completionBlock) {
                completionBlock(exchangeRateResult);
            }
        } else {
            MCExchangeRateStatus exchangeRateFetchStatus = invalid;
            [self setStatus:[NSNumber numberWithShort:exchangeRateFetchStatus]];
            NSLog(@"MCExchangeRate status is invalid");
            if (completionBlock) {
                completionBlock(nil);
            }
        }
       
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
