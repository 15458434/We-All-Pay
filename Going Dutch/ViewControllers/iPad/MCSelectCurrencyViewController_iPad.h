//
//  MCSelectCurrencyViewController_iPad.h
//  We all pay
//
//  Created by Mark Cornelisse on 28/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCThisPaymentProtocol.h"
#import "MCDismissMeBlockProtocol.h"

@class MCPayment;

@interface MCSelectCurrencyViewController_iPad : UIViewController <MCThisPaymentProtocol, MCDismissMeBlockProtocol>

@property (nonatomic, strong) MCPayment *thisPayment;
@property (strong, nonatomic) void (^dismissMe)();

@end
