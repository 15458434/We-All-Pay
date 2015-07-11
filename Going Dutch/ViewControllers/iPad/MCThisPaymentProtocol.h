//
//  MCThisPaymentProtocol.h
//  We all pay
//
//  Created by Mark Cornelisse on 06-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Foundation;

@class MCPayment;

@protocol MCThisPaymentProtocol <NSObject>

- (MCPayment *)thisPayment;
- (void)setThisPayment:(MCPayment *)payment;

@end
