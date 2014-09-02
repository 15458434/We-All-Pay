//
//  MCReturnPaymentViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 07-02-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "MCCancelDoneTableViewController.h"

@class MCSharedBill;

@class MCTwoLabelsTitleView;
@class MCTableEmptyMessage;

@class MCSharedBillPageViewController;

@interface MCReturnPaymentViewController : MCCancelDoneTableViewController <MFMailComposeViewControllerDelegate>
{
    MCTwoLabelsTitleView *twoLabelTitleView;
    MCTableEmptyMessage *emptyMessage;
}

- (IBAction)sendAsEmailButtonPressed:(id)sender;
- (IBAction)mainCancelButtonPressed:(id)sender;

- (id)initWithBill:(MCSharedBill *)thisBill;

@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, weak) MCSharedBillPageViewController *sendMailObject;

@end
