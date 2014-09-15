//
//  MCDataController.m
//  We all pay
//
//  Created by Mark Cornelisse on 28-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCDataStorage.h"

#import "MCxRatesController+X_RatesAddOn.h"
#import "MCxRatesCurrency.h"

#import "MCNetworkTools.h"

typedef NS_ENUM(BOOL, MCReversing) {
    isNotReversing,
    isReversing
};

typedef NS_ENUM(BOOL, MCStillBooting) {
    isStillBooting,
    isNotBooting
};

typedef NS_ENUM(BOOL, MCDecodingRestorableState) {
    isNotDecodingRestorableState,
    isDecodingRestorableState
};

// State Restoration Strings
NSString * const MCStateRestoreSourceAmount = @"MCStateRestoreSourceAmount";
NSString * const MCStateRestoreExchangeRate = @"MCStateRestoreExchangeRate";
NSString * const MCStateRestoreDestinationAmount = @"MCStateRestoreDesinationAmount";
NSString * const MCStateRestoreSourceCurrencyObject = @"MCStateRestoreSourceCurrencyObject";
NSString * const MCStateRestoreDestinationCurrencyObject = @"MCStateRestoreDestinationCurrencyObject";

@interface MCDataStorage ()

@property (nonatomic) MCDecodingRestorableState decodingState;
@property (nonatomic) MCReversing reversing;
@property (nonatomic) MCStillBooting stillBooting;
@property (nonatomic) short indicatorStartCount;

@end

@implementation MCDataStorage

#pragma mark - Actions

- (IBAction)reverseConversion:(id)sender
{
    _reversing = isReversing;
    
    MCxRatesCurrency *selectedSourceCurrency = [[_sourceController selectedObjects] firstObject];
    MCxRatesCurrency *selectedDestinationCurrency = [[_destinationController selectedObjects] firstObject];
    [_sourceController setSelectedObjects:@[selectedDestinationCurrency]];
    [_destinationController setSelectedObjects:@[selectedSourceCurrency]];
    
    NSInteger selectedRowSourceCurrency = [_sourceTableView selectedRow];
    NSInteger selectedRowDestinationCurrency = [_destinationTableView selectedRow];
    [_sourceTableView scrollRowToVisible:selectedRowSourceCurrency];
    [_destinationTableView scrollRowToVisible:selectedRowDestinationCurrency];
    
    [self getXRate];
    _reversing = isNotReversing;
}

- (IBAction)refreshCurrentExchangeRateValue:(id)sender
{
    [self getXRate];
}

#pragma mark - Private in this class.

- (void)startIndicator
{
    _indicatorStartCount++;
    if (_indicatorStartCount == 1) {
        [_activityIndicator startAnimation:self];
        [_exchangeRateField setHidden:YES];
    }
}

- (void)stopIndicator
{
    _indicatorStartCount--;
    if (_indicatorStartCount == 0) {
        [_activityIndicator stopAnimation:self];
        [_exchangeRateField setHidden:NO];
    }
}

- (void)getXRate
{
    if (_decodingState == isDecodingRestorableState || _stillBooting == isStillBooting) {
        return;
    }
    NSString *sourceCurrencyISOCode = [[[_sourceController selectedObjects] firstObject] valueForKeyPath:@"currencyISOCode"];
    NSString *destinationCurrencyISOCode = [[[_destinationController selectedObjects] firstObject] valueForKey:@"currencyISOCode"];
    if (sourceCurrencyISOCode == nil) {
        return;
    }
    if (destinationCurrencyISOCode == nil) {
        return;
    }
    
    if (isInternetConnection()) {
        _xRatesController = [MCxRatesController new];
        NSLog(@"Refetch Started.");
        [self startIndicator];
        [_xRatesController getExchangeRateFrom:sourceCurrencyISOCode to:destinationCurrencyISOCode withCompletionHandler:^(NSDictionary *exchangeRateResult) {
            [self setExchangeRate:[exchangeRateResult objectForKey:MCCurrencyExchangeRate]];
            if (_exchangeRate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self stopIndicator];
                    [self setDestinationAmount:@([_sourceAmount doubleValue] * [_exchangeRate doubleValue])];
                    NSLog(@"Refetch done.");
                });
            }
        }];
    } else {
        NSError *error = [NSError errorWithDomain:@"com.greenhair" code:1 userInfo:@{NSLocalizedDescriptionKey: @"No internet connection."}];
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert beginSheetModalForWindow:[[NSApplication sharedApplication] keyWindow] completionHandler:^(NSModalResponse returnCode) {
            NSLog(@"Return code: %ld", (long)returnCode);
        }];
    }
}

#pragma mark - Inherited from super.

- (void)awakeFromNib
{
    _indicatorStartCount = 0;
    [super awakeFromNib];
    
    _decodingState = isNotDecodingRestorableState;
    _reversing = isNotReversing;
    _stillBooting = isStillBooting;
    
    // Don't use instance variables.
    self.sourceCurrencies = [MCxRatesController getAllCurrencies];
    self.destinationCurrencies = [MCxRatesController getAllCurrencies];
    self.sourceAmount = @1.0;
    _stillBooting = isNotBooting;
    [self getXRate];
    
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

- (void)setNilValueForKey:(NSString *)key
{
    NSLog(@"Ik heb een fiets!");
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    // If Reverse is pressed don't do anything.
    NSString *sourceName = [[[_sourceController selectedObjects] firstObject] currencyName];
    NSString *destinationName = [[[_destinationController selectedObjects] firstObject] currencyName];
    [self setSourceAmountLabel:sourceName];
    [self setDestinationAmountlabel:destinationName];
    if (_reversing == isNotReversing || _decodingState == isNotDecodingRestorableState) {
        [self getXRate];
        [self invalidateRestorableState];
//        }
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

#pragma mark - NSWindowDelegate

- (void)window:(NSWindow *)window didDecodeRestorableState:(NSCoder *)state
{
    _decodingState = isDecodingRestorableState;
    self.sourceCurrencies = [MCxRatesController getAllCurrencies];
    self.destinationCurrencies = [MCxRatesController getAllCurrencies];
    [self setSourceAmount:[state decodeObjectForKey:MCStateRestoreSourceAmount]];
    [self setDestinationAmount:[state decodeObjectForKey:MCStateRestoreDestinationAmount]];
    [self setExchangeRate:[state decodeObjectForKey:MCStateRestoreExchangeRate]];
    [[self sourceController] setSelectedObjects:[state decodeObjectForKey:MCStateRestoreSourceCurrencyObject]];
    [[self destinationController] setSelectedObjects:[state decodeObjectForKey:MCStateRestoreDestinationCurrencyObject]];
    _decodingState = isNotDecodingRestorableState;
    [self getXRate];
}

- (void)window:(NSWindow *)window willEncodeRestorableState:(NSCoder *)state
{
    [state encodeObject:_sourceAmount forKey:MCStateRestoreSourceAmount];
    [state encodeObject:_destinationAmount forKey:MCStateRestoreDestinationAmount];
    [state encodeObject:[_sourceController selectedObjects] forKey:MCStateRestoreSourceCurrencyObject];
    [state encodeObject:[_destinationController selectedObjects] forKey:MCStateRestoreDestinationCurrencyObject];
    [state encodeObject:_exchangeRate forKey:MCCurrencyExchangeRate];
}

@end
