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
    
    [_toCurrencySelector removeAllItems];
    [_toCurrencySelector addItemsWithTitles:[MCxRatesController getAvailableCurrencies]];
    [_fromCurrencySelector removeAllItems];
    [_fromCurrencySelector addItemsWithTitles:[MCxRatesController getAvailableCurrencies]];
}

- (IBAction)fromCurrencySelected:(id)sender
{
    MCxRatesController *thisXRatesController = [self getXRatesController];
    [thisXRatesController getExchangeRateFrom:[_toCurrencySelector titleOfSelectedItem] to:[_fromCurrencySelector titleOfSelectedItem] withCompletionHandler:^(NSDictionary *exchangeRateResult) {
        NSString *rate = [exchangeRateResult valueForKeyPath:@"query.results.row.rate"];
        [_exchangeRate setStringValue:rate];
    }];
}

- (IBAction)toCurrencySelected:(id)sender
{
    MCxRatesController *thisXRatesController = [self getXRatesController];
    [thisXRatesController getExchangeRateFrom:[_toCurrencySelector titleOfSelectedItem] to:[_fromCurrencySelector titleOfSelectedItem] withCompletionHandler:^(NSDictionary *exchangeRateResult) {
        NSString *rate = [exchangeRateResult valueForKeyPath:@"query.results.row.rate"];
        [_exchangeRate setStringValue:rate];
    }];
}


@end
