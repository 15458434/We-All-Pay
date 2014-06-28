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
    MCxRatesController *_xRatesController;
}
@property (copy) NSMutableArray *sourceCurrencies;
@property (copy) NSMutableArray *destinationCurrencies;
@property (readwrite) NSNumber *exchangeRate;

@property (weak) IBOutlet NSTextField *sourceAmount;
@property (weak) IBOutlet NSTextField *destinationAmount;

@property (weak) IBOutlet NSArrayController *sourceController;
@property (weak) IBOutlet NSArrayController *destinationController;


@end
