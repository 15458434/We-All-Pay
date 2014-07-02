//
//  MCDataController.h
//  We all pay
//
//  Created by Mark Cornelisse on 28-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Foundation;
@import Cocoa;

@class MCxRatesController;

@interface MCDataStorage : NSObject <NSTableViewDelegate>
{
    __weak NSTextField *_originalAmountField;
    __weak NSTextField *_exchangeRateField;
    __weak NSTextField *_convertedAmountField;
    
    MCxRatesController *_xRatesController;
}
@property (copy) NSMutableArray *sourceCurrencies;
@property (copy) NSMutableArray *destinationCurrencies;

@property (readwrite) NSNumber *exchangeRate;
@property (readwrite) NSNumber *sourceAmount;
@property (readwrite) NSNumber *destinationAmount;

@property (weak) IBOutlet NSArrayController *sourceController;
@property (weak) IBOutlet NSArrayController *destinationController;


@property (weak) IBOutlet NSTextField *originalAmountField;
@property (weak) IBOutlet NSTextField *convertedAmountField;
@property (weak) IBOutlet NSTextField *exchangeRateField;

- (IBAction)reverseConversion:(id)sender;

@end
