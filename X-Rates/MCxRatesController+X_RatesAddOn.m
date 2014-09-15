//
//  MCxRatesController+X_RatesAddOn.m
//  We all pay
//
//  Created by Mark Cornelisse on 28-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCxRatesController+X_RatesAddOn.h"

#import "MCxRatesCurrency.h"

@implementation MCxRatesController (X_RatesAddOn)

+ (NSMutableArray *)getAllCurrencies
{
    NSArray *isoCodes = [MCxRatesController getAvailableCurrenciesISOCodesOrderedOnCurrencyName];
    NSLog(@"%lu", isoCodes.count);
    NSDictionary *currencyDictionary = [MCxRatesController getCurrencyDictionary];
    NSMutableArray *currencies = [NSMutableArray new];
    for (NSString *isoCode in isoCodes) {
        MCxRatesCurrency *currency = [MCxRatesCurrency new];
        [currency setCurrencyISOCode:isoCode];
        NSString *nameKeyPath = [NSString stringWithFormat:@"%@.name", isoCode];
        [currency setCurrencyName:[currencyDictionary valueForKeyPath:nameKeyPath]];
        [currency setCurrencySymbol:[MCxRatesController getSymbolForCurrencyISOCode:isoCode]];
        [currencies addObject:currency];
//        NSLog(@"Currency Added: %@", [currency currencyName]);
    }
    return currencies;
}

@end
