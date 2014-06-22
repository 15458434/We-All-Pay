//
//  MCMainXRatesViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 21-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Cocoa;

@class MCxRatesController;

@interface MCMainXRatesViewController : NSViewController

@property (weak) IBOutlet NSPopUpButton *fromCurrencySelector;
@property (weak) IBOutlet NSPopUpButton *toCurrencySelector;
@property (weak) IBOutlet NSTextField *exchangeRate;

- (IBAction)fromCurrencySelected:(id)sender;
- (IBAction)toCurrencySelected:(id)sender;

@end
