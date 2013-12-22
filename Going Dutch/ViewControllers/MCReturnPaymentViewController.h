//
//  MCReturnPaymentViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 07-02-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <MessageUI/MessageUI.h>

#import "MCCancelDoneTableViewController.h"

@class MCSharedBill;
@class MCTwoLabelsTitleView;

@class MCSharedBillTableViewController;

@interface MCReturnPaymentViewController : MCCancelDoneTableViewController <MFMailComposeViewControllerDelegate>
{
    NSMutableArray *paymentsAfterwards;
    
    __strong IBOutlet MCTwoLabelsTitleView *twoLabelTitleView;
}

- (IBAction)sendAsEmailButtonPressed:(id)sender;
- (IBAction)mainCancelButtonPressed:(id)sender;

- (id)initWithBill:(MCSharedBill *)thisBill;

@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, weak) MCSharedBillTableViewController *sendMailObject;

@end
