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

@interface MCSharedBillTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate, MCTonightsBillTransfer, MCIndexProtocol>
{
    __strong IBOutlet MCTwoLabelsTitleView *twoLabelTitleView;
    MCTableEmptyMessage *emptyMessage;
    
    UIBarButtonItem *mailButton;
    UIBarButtonItem *returnPaymentButton;
}

@property (nonatomic, weak) id<MCIsEditingProtocol> myParent;
@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) MCSharedBillPageViewController *mailDelegate;
@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, readonly) BOOL didSomethingChange;

@property (nonatomic) NSInteger index;

// Only accessible through backgroundContext
@property (nonatomic, strong) MCSharedBill *writableTonightsBill;

- (void)writableTonightsBillIsCreated:(NSNotification *)notification;

@end
