//
//  MCSharedBillTableViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>
#import "MCTonightsBillTransfer.h"
#import "MCIndexProtocol.h"

@class MCSharedBill;
@class MCAllTripsTableViewController;
@class MCTwoLabelsTitleView;
@class MCTextFieldAndLabelTitleView;
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

//- (id)initWithSharedBill:(MCSharedBill *)tBill;


- (IBAction)mailButtonPressed:(id)sender;

@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) MCSharedBillPageViewController *mailDelegate;
@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, readonly) BOOL didSomethingChange;

@property (nonatomic) NSInteger index;

// Only accessible through backgroundContext
@property (nonatomic, strong) MCSharedBill *writableTonightsBill;

- (void)writableTonightsBillIsCreated:(NSNotification *)notification;

@end
