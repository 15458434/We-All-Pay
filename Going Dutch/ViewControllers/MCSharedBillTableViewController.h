//
//  MCSharedBillTableViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MCPaymentViewController.h"

@class MCSharedBill;
@class MCAllTripsTableViewController;
@class MCPaymentViewController;
@class MCTextFieldAndLabelTitleView;

@interface MCSharedBillTableViewController : UITableViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate, MCPaymentViewControllerDelegate, UITextFieldDelegate>
{
    __strong IBOutlet MCTextFieldAndLabelTitleView *twoLabelTitleView;
}

- (id)initWithSharedBill:(MCSharedBill *)tBill;
- (void)addPayment:(id)sender;

@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, readonly) BOOL didSomethingChange;

@end
