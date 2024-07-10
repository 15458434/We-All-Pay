//
//  MCCurrency+addons.m
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCCurrency+addons.h"

#import "We_all_pay-Swift.h"

@implementation MCCurrency (addons)

+ (MCCurrency *)generateCurrencyFromSelectedLocaleForContext:(NSManagedObjectContext *)context;
{
#ifdef DEBUG
    NSLog(@"%@ generateCurrencyFromSelectedLocaleForContext", self);
#endif
    NSParameterAssert(context);
    NSString *currencyCodeFromCurrentLocale = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
    // currencyCode from Current locale is necessary. Set the current locale for the simulator.
    NSParameterAssert(currencyCodeFromCurrentLocale);
    NSString *currencyNameFromCurrentLocale = [[[WeAllPayStoreController defaultStore] fetcher] currencyController][currencyCodeFromCurrentLocale];
    NSString *currencySymbolFromCurrentLocale = [[[[WeAllPayStoreController defaultStore] fetcher] currencyController] currencySymbol:currencyCodeFromCurrentLocale];
    MCCurrency *newCurrency = [[MCCurrency alloc] initWithContext:context];
    newCurrency.code = currencyCodeFromCurrentLocale;
    newCurrency.name = currencyNameFromCurrentLocale;
    newCurrency.symbol = currencySymbolFromCurrentLocale;
    newCurrency.isStillValid = @YES;
    return newCurrency;
}

+ (MCCurrency *)currencyFrom:(NSString *)code fromContext:(NSManagedObjectContext *)context
{
    CurrencyController *currencyController = [[[WeAllPayStoreController defaultStore] fetcher] currencyController];
    MCCurrency *newCurrency = [[MCCurrency alloc] initWithContext:context];
    newCurrency.name = currencyController[code];
    newCurrency.symbol = [currencyController currencySymbol:code];
    newCurrency.code = code;
    newCurrency.isStillValid = @YES;
    return newCurrency;
}

+ (void)addAllAvailableCurrenciesToContext:(NSManagedObjectContext *)context
{
    // TODO: Why is this only used for testing?
    NSArray *currencies = [[[[WeAllPayStoreController defaultStore] fetcher] currencyController] currencies];
    for (NSDictionary *currency in currencies) {
        // For each currencyCode add it.
        MCCurrency *newCurrency = [[MCCurrency alloc] initWithContext:context];
        newCurrency.isStillValid = @YES;
        newCurrency.name = currency[@"name"];
        newCurrency.code = currency[@"code"];
        newCurrency.symbol = [[[[WeAllPayStoreController defaultStore] fetcher] currencyController] currencySymbol:currency[@"code"]];
        NSLog(@"Generated MCCurrency: %@", newCurrency);
    }
}

- (BOOL)isEqualToMCCurrency:(MCCurrency *)object {
    return [self.code isEqualToString:object.code];
}

@end
