//
//  MCDataController.m
//  We all pay
//
//  Created by Mark Cornelisse on 28-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCDataStorage.h"

#import "MCxRatesController+X_RatesAddOn.h"
#import "MCCurrency.h"

@implementation MCDataStorage

#pragma mark - Inherited from super.

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Don't use instance variables.
    self.sourceCurrencies = [MCxRatesController getAllCurrencies];
    self.destinationCurrencies = [MCxRatesController getAllCurrencies];
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    _xRatesController = [MCxRatesController new];
    NSString *sourceCurrencyISOCode = [[[_sourceController selectedObjects] firstObject] valueForKeyPath:@"currencyISOCode"];
    NSString *destinationCurrencyISOCode = [[[_destinationController selectedObjects] firstObject] valueForKey:@"currencyISOCode"];
    [_xRatesController getExchangeRateFrom:sourceCurrencyISOCode to:destinationCurrencyISOCode withCompletionHandler:^(NSDictionary *exchangeRateResult) {
        self.exchangeRate = [exchangeRateResult valueForKeyPath:@"query.results.row.rate"];
    }];
}

@end
