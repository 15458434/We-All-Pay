//
//  MCSharedBillViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 02-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

#import "MCAddressBookDataReceiver.h"
#import "MCTonightsBillTransfer.h"
#import "MCThisPersonProtocol.h"
#import "MCThisPaymentProtocol.h"

@class MCSharedBill;

@interface MCSharedBillViewController_iPad : UIViewController <MCTonightsBillTransfer, MCAddressBookReceiverDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) MCAddressBookDataReceiver *personReceiver;

@property (strong, nonatomic) MCSharedBill *tonightsBill;
@property (strong, nonatomic) MCSharedBill *writableTonightsBill;

@end
