//
//  MCTonightsBillTransfer.h
//  We all pay
//
//  Created by Mark Cornelisse on 28-03-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Foundation;

@class MCSharedBill;

// Notification Message that writableTonightsBill is ready to be used.
extern NSString * const MCWritableTonightsBillReady;
extern NSString * const MCwritableTonightsBillKey;

@protocol MCTonightsBillTransfer <NSObject>

// Accessed on mainThread.
@property (strong, nonatomic) MCSharedBill *tonightsBill;

@optional
// Accessed on privateThread
@property (strong, nonatomic) MCSharedBill *writableTonightsBill;

@end

