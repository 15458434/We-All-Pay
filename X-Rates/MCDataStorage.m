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
    [self setSourceAmount:@1.0];
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    _xRatesController = [MCxRatesController new];
    NSString *sourceCurrencyISOCode = [[[_sourceController selectedObjects] firstObject] valueForKeyPath:@"currencyISOCode"];
    NSString *destinationCurrencyISOCode = [[[_destinationController selectedObjects] firstObject] valueForKey:@"currencyISOCode"];
    [_xRatesController getExchangeRateFrom:sourceCurrencyISOCode to:destinationCurrencyISOCode withCompletionHandler:^(NSDictionary *exchangeRateResult) {
//        NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
//        NSString *localeIdentifier = [exchangeRateResult valueForKeyPath:@"query.lang"];
//        [numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:localeIdentifier]];
//        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
//        [self setExchangeRate:[numberFormatter numberFromString:[exchangeRateResult valueForKeyPath:@"query.results.row.rate"]]];
        self.exchangeRate = [exchangeRateResult valueForKeyPath:@"query.results.row.rate"];
        if (_exchangeRate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setDestinationAmount:@([_sourceAmount doubleValue] * [_exchangeRate doubleValue])];
            });
        }
    }];
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidEndEditing:(NSNotification *)notification
{
    if([notification object] == _originalAmountField)
    {
        [self setDestinationAmount:@(_sourceAmount.doubleValue * _exchangeRate.doubleValue)];
    }
    if([notification object] == _convertedAmountField)
    {
        [self setSourceAmount:@([_destinationAmount doubleValue] / [_exchangeRate doubleValue])];
    }
}


@end
