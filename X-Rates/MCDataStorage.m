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

typedef NS_ENUM(BOOL, MCReversing) {
    isNotReversing,
    isReversing
};

@implementation MCDataStorage
{
    MCReversing reversing;
}

#pragma mark - Actions

- (IBAction)reverseConversion:(id)sender
{
    reversing = isReversing;
    
    MCCurrency *selectedSourceCurrency = [[_sourceController selectedObjects] firstObject];
    MCCurrency *selectedDestinationCurrency = [[_destinationController selectedObjects] firstObject];
    [_sourceController setSelectedObjects:@[selectedDestinationCurrency]];
    [_destinationController setSelectedObjects:@[selectedSourceCurrency]];
    
    NSInteger selectedRowSourceCurrency = [_sourceTableView selectedRow];
    NSInteger selectedRowDestinationCurrency = [_destinationTableView selectedRow];
    [_sourceTableView scrollRowToVisible:selectedRowSourceCurrency];
    [_destinationTableView scrollRowToVisible:selectedRowDestinationCurrency];
    
    [self getXRate];
    reversing = isNotReversing;
}

- (IBAction)refreshCurrentExchangeRateValue:(id)sender
{
    [self getXRate];
}

#pragma mark - New in this class.

- (void)getXRate
{
    _xRatesController = [MCxRatesController new];
    NSString *sourceCurrencyISOCode = [[[_sourceController selectedObjects] firstObject] valueForKeyPath:@"currencyISOCode"];
    NSString *destinationCurrencyISOCode = [[[_destinationController selectedObjects] firstObject] valueForKey:@"currencyISOCode"];
    [_xRatesController getExchangeRateFrom:sourceCurrencyISOCode to:destinationCurrencyISOCode withCompletionHandler:^(NSDictionary *exchangeRateResult) {
        [self setExchangeRate:[exchangeRateResult objectForKey:MCExchangeRate]];
        if (_exchangeRate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setDestinationAmount:@([_sourceAmount doubleValue] * [_exchangeRate doubleValue])];
                NSLog(@"Refetch done.");
            });
        }
    }];
}

#pragma mark - Inherited from super.

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    reversing = isNotReversing;
    
    // Don't use instance variables.
    self.sourceCurrencies = [MCxRatesController getAllCurrencies];
    self.destinationCurrencies = [MCxRatesController getAllCurrencies];
    [self setSourceAmount:@1.0];
    
    // LayoutConstraints for the source and destination currency amount.
    NSLayoutConstraint *left= [NSLayoutConstraint constraintWithItem:_sourceScrollView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_originalAmountField attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:_destinationScrollView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_convertedAmountField attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    [[self view] addConstraints:@[left, right]];
}

- (void)loadView
{
    [super loadView];
    
    // Constraint for alignment of the sourceAmountField and destinationField to the center of the sourceScrollView and destinationScrollView.
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    // If Reverse is pressed don't do anything. 
    if (reversing == isNotReversing) {
        [self getXRate];
    }
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)notification
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
