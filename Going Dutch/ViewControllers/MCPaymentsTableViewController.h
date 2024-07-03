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

#import "MCTonightsBillTransfer.h"
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
@interface MCPaymentsTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate, MCTonightsBillTransfer, MCIndexProtocol>

@property (nonatomic, strong) MCEventModel *eventModel;
@property (nonatomic, strong) MCToggleModel *isEditingModel;

@property (nonatomic, strong) MCTableEmptyMessage *emptyMessage;

@property (nonatomic, weak) MCSharedBillPageViewController *mailDelegate;
@property (nonatomic, strong) MCSharedBill *tonightsBill __deprecated;

@property (nonatomic) NSInteger index;

// Only accessible through backgroundContext
@property (nonatomic, strong) MCSharedBill *writableTonightsBill __deprecated;

@end
