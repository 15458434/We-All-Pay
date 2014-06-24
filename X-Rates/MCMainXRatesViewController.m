//
//  MCMainXRatesViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 21-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCMainXRatesViewController.h"

#import "MCxRatesController.h"

@interface MCMainXRatesViewController ()
{
    MCxRatesController *_xRatesController;
}

@end

@implementation MCMainXRatesViewController

#pragma mark - Private in this class.

- (MCxRatesController *)getXRatesController
{
    if (_xRatesController) {
        return _xRatesController;
    } else {
        _xRatesController = [MCxRatesController new];
        return _xRatesController;
    }
}

- (void)updateCurrencyValue
{
    MCxRatesController *thisXRatesController = [self getXRatesController];
    NSInteger indexOfSelectedFromCurrency = [_fromCurrencySelector indexOfSelectedItem];
    NSInteger indexOfSelectedToCurrency = [_toCurrencySelector indexOfSelectedItem];
    NSString *fromCurrencyISOCode = [_sortedCurrencies objectAtIndex:indexOfSelectedFromCurrency];
    NSString *toCurrencyISOCode = [_sortedCurrencies objectAtIndex:indexOfSelectedToCurrency];
    
    [thisXRatesController getExchangeRateFrom:fromCurrencyISOCode to:toCurrencyISOCode withCompletionHandler:^(NSDictionary *exchangeRateResult) {
        NSString *rate = [exchangeRateResult valueForKeyPath:@"query.results.row.rate"];
        [_exchangeRate setStringValue:rate];
    }];
}

#pragma mark - Inherited from super.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSMutableArray *arrayOfSortedCurrencyNames = [NSMutableArray new];
    _sortedCurrencies = [MCxRatesController getAvailableCurrenciesISOCodesOrderedOnCurrencyName];
    for (NSString *currencyISOCode in _sortedCurrencies) {
        NSMutableString *currencyName = [[[NSLocale currentLocale] displayNameForKey:NSLocaleCurrencyCode value:currencyISOCode] mutableCopy];
        [currencyName appendFormat:@" (%@)", [MCxRatesController getSymbolForCurrencyISOCode:currencyISOCode]];
        [arrayOfSortedCurrencyNames addObject:currencyName];
    }
    
    [_toCurrencySelector removeAllItems];
    [_toCurrencySelector addItemsWithTitles:arrayOfSortedCurrencyNames];
    [_fromCurrencySelector removeAllItems];
    [_fromCurrencySelector addItemsWithTitles:arrayOfSortedCurrencyNames];
}

- (IBAction)fromCurrencySelected:(id)sender
{
    [self updateCurrencyValue];
}

- (IBAction)toCurrencySelected:(id)sender
{
    [self updateCurrencyValue];
}


@end
