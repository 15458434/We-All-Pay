//
//  MCReturnPaymentViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 07-02-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import MessageUI;

@class MCSharedBill;

@class MCTwoLabelsTitleView;
@class MCTableEmptyMessage;

@class MCSharedBillPageViewController;

@interface MCReturnPaymentViewController : UITableViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) MCTwoLabelsTitleView *twoLabelTitleView;

@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, weak) MCSharedBillPageViewController *sendMailObject;

- (IBAction)sendAsEmailButtonPressed:(id)sender;
- (IBAction)mainCancelButtonPressed:(id)sender;

- (id)initWithBill:(MCSharedBill *)thisBill;

@end
