//
//  MCSharedBillTableViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import CoreData;
@import MessageUI;
@import NotificationCenter;

#import "MCGenericInterstitialAdTableViewController.h"

#import "MCTonightsBillTransfer.h"
#import "MCIndexProtocol.h"
#import "MCIsEditingProtocol.h"

@class MCSharedBill;
@class MCAllTripsTableViewController;
@class MCTwoLabelsTitleView;
@class MCTableEmptyMessage;
@class MCSharedBillPageViewController;

@protocol MCReturnPaymentViewControllerDelegate <NSObject>

- (void)sendAsMail:(id)sender;

@end

__attribute__((objc_subclassing_restricted))
@interface MCSharedBillTableViewController : MCGenericInterstitialAdTableViewController <NSFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate, MCTonightsBillTransfer, MCIndexProtocol>

@property (nonatomic, strong) MCTableEmptyMessage *emptyMessage;

@property (nonatomic, weak) id<MCIsEditingProtocol> myParent;
@property (nonatomic, weak) MCSharedBillPageViewController *mailDelegate;
@property (nonatomic, strong) MCSharedBill *tonightsBill;

@property (nonatomic) NSInteger index;

// Only accessible through backgroundContext
@property (nonatomic, strong) MCSharedBill *writableTonightsBill;

- (void)writableTonightsBillIsCreated:(NSNotification *)notification;

@end
