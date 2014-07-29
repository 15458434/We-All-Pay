//
//  MCSelectCurrencyViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 28/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import UIKit;
#import "MCThisPaymentProtocol.h"

@class MCPayment;

@interface MCSelectCurrencyViewController : UIViewController <MCThisPaymentProtocol>

@property (nonatomic, strong) MCPayment *thisPayment;

@end
