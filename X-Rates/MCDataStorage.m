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

#import "XRCurrencyStoreController.h"

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

typedef NS_ENUM(BOOL, MCConversionDirection) {
    fromSourceToDestination,
    fromDestinationToSource
};

// State Restoration Strings
NSString * const MCStateRestoreSourceAmount = @"MCStateRestoreSourceAmount";
NSString * const MCStateRestoreExchangeRate = @"MCStateRestoreExchangeRate";
NSString * const MCStateRestoreDestinationAmount = @"MCStateRestoreDesinationAmount";
NSString * const MCStateRestoreSourceCurrencyObject = @"MCStateRestoreSourceCurrencyObject";
NSString * const MCStateRestoreDestinationCurrencyObject = @"MCStateRestoreDestinationCurrencyObject";
NSString * const MCConversionDirectionKey = @"MCConversionDirectionKey";

@interface MCDataStorage ()

@property (nonatomic) MCDecodingRestorableState decodingState;
@property (nonatomic) MCReversing reversing;
@property (nonatomic) MCStillBooting stillBooting;
@property (nonatomic) MCConversionDirection conversionDirection;

@property (nonatomic) short indicatorStartCount;
@property (nonatomic, strong) NSDate *requestTimeOfLastReceivedExchangeRateResult;

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
    
    if (_conversionDirection == fromSourceToDestination) {
        [self setDestinationAmount:_sourceAmount];
        [self setSourceAmount:nil];
        _conversionDirection = fromDestinationToSource;
    } else {
        [self setSourceAmount:_destinationAmount];
        [self setDestinationAmount:nil];
        _conversionDirection = fromSourceToDestination;
    }
    
    _reversing = isNotReversing;
    [self getXRate];
}

- (IBAction)refreshCurrentExchangeRateValue:(id)sender
{
    [self getXRate];
}

#pragma mark - Private in this class.

- (void)startIndicator
{
    _indicatorStartCount++;
#ifdef DEBUG
    NSLog(@"startIndicator: %d", _indicatorStartCount);
#endif
    if (_indicatorStartCount == 1) {
        [_activityIndicator startAnimation:self];
        [_exchangeRateField setHidden:YES];
    }
}

- (void)stopIndicator
{
#ifdef DEBUG
    NSLog(@"stopIndicator: %d", _indicatorStartCount);
#endif
    _indicatorStartCount--;
    if (_indicatorStartCount == 0) {
        [_activityIndicator stopAnimation:self];
        [_exchangeRateField setHidden:NO];
    }
}

- (void)getXRate
{
    if (_decodingState == isDecodingRestorableState || _stillBooting == isStillBooting || _reversing == isReversing) {
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
    
    NSDate *now = [NSDate date];
    if (isInternetConnection()) {
        _xRatesController = [MCxRatesController new];
        [self startIndicator];
        [_xRatesController getExchangeRateFrom:sourceCurrencyISOCode to:destinationCurrencyISOCode withCompletionHandler:^(NSDictionary *exchangeRateResult) {
            if ([_requestTimeOfLastReceivedExchangeRateResult isLessThan:now]) {
                _requestTimeOfLastReceivedExchangeRateResult = now;
                [self setExchangeRate:[exchangeRateResult objectForKey:MCCurrencyExchangeRate]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopIndicator];
            });
            if (_exchangeRate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_conversionDirection == fromSourceToDestination) {
                        [self setDestinationAmount:@([_sourceAmount doubleValue] * [_exchangeRate doubleValue])];
                    } else {
                        [self setSourceAmount:@([_destinationAmount doubleValue] / [_exchangeRate doubleValue])];
                    }
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
    [[XRCurrencyStoreController sharedStore] prepareStoreWithCompletionHandler:^{
#ifdef DEBUG
        NSLog(@"XRCurrencyStore is ready");
#endif
    }];
    _indicatorStartCount = 0;
    _requestTimeOfLastReceivedExchangeRateResult = [NSDate date];
    [super awakeFromNib];
    
    _decodingState = isNotDecodingRestorableState;
    _reversing = isNotReversing;
    _stillBooting = isStillBooting;
    _conversionDirection = fromSourceToDestination;
    
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
    }
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)notification
{
    if([notification object] == _originalAmountField)
    {
        _conversionDirection = fromSourceToDestination;
        [self setDestinationAmount:@(_sourceAmount.doubleValue * _exchangeRate.doubleValue)];
    }
    if([notification object] == _convertedAmountField)
    {
        _conversionDirection = fromDestinationToSource;
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
    self.conversionDirection = [state decodeBoolForKey:MCConversionDirectionKey];
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
    [state encodeBool:_conversionDirection forKey:MCConversionDirectionKey];
}

@end
