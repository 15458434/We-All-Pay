//
//  MCxRatesController+X_RatesAddOn.m
//  We all pay
//
//  Created by Mark Cornelisse on 28-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCxRatesController+X_RatesAddOn.h"

#import "MCCurrency.h"

@implementation MCxRatesController (X_RatesAddOn)

+ (NSMutableArray *)getAllCurrencies
{
    NSArray *isoCodes = [MCxRatesController getAvailableCurrenciesISOCodesOrderedOnCurrencyName];
    NSDictionary *currencyDictionary = [MCxRatesController getCurrencyDictionary];
    NSMutableArray *currencies = [NSMutableArray new];
    for (NSString *isoCode in isoCodes) {
        MCCurrency *currency = [MCCurrency new];
        [currency setCurrencyISOCode:isoCode];
        NSString *nameKeyPath = [NSString stringWithFormat:@"%@.name", isoCode];
        [currency setCurrencyName:[currencyDictionary valueForKeyPath:nameKeyPath]];
        [currency setCurrencySymbol:[MCxRatesController getSymbolForCurrencyISOCode:isoCode]];
        [currencies addObject:currency];
    }
    return currencies;
}

@end
