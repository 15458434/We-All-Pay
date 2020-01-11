//
//  MCSharedBillViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 02-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import UIKit;

#import "MCGenericAdBannerViewController.h"

#import "MCTonightsBillTransfer.h"
#import "MCThisPaymentProtocol.h"

@class MCSharedBill;

@interface MCSharedBillViewController_iPad : MCGenericAdBannerViewController <MCTonightsBillTransfer, UITextFieldDelegate>

@property (strong, nonatomic) MCSharedBill *tonightsBill;
@property (strong, nonatomic) MCSharedBill *writableTonightsBill;

@end
