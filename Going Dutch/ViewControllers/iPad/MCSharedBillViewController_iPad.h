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

@class MCSharedBill;

@interface MCSharedBillViewController_iPad : UIViewController <MCTonightsBillPut, MCTonightsBillGet, MCAddressBookReceiverDelegate, UITextFieldDelegate>
{
    __weak IBOutlet UITextField *tripNameField;
    
    MCAddressBookDataReceiver *personReceiver;
}
@property (strong, nonatomic) MCSharedBill *tonightsBill;

@end
