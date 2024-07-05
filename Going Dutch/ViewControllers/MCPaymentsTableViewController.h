//
//  MCPaymentsTableViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import CoreData;
@import MessageUI;
@import NotificationCenter;

#import "MCIndexProtocol.h"
#import "We_all_pay-Swift.h"

@class MCSharedBill;
@class MCAllTripsTableViewController;
@class MCTwoLabelsTitleView;
@class MCTableEmptyMessage;
@class MCSharedBillPageViewController;

@protocol MCReturnPaymentViewControllerDelegate <NSObject>

- (void)sendAsMail:(id)sender;

@end

__attribute__((objc_subclassing_restricted))
NS_SWIFT_NAME(PaymentsTableViewController)
@interface MCPaymentsTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate, MCIndexProtocol>

@property (nonatomic, strong) MCEventModel *eventModel;
@property (nonatomic, strong) MCToggleModel *isEditingModel;

@property (nonatomic, strong) MCTableEmptyMessage *emptyMessage;

@property (nonatomic, weak) MCSharedBillPageViewController *mailDelegate;

@property (nonatomic) NSInteger index;

@end
