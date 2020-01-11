//
//  MCPaymentViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 29-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import CoreData;
@import NotificationCenter;

#import "MCThisPaymentProtocol.h"
#import "MCPathComponentsToOpenProtocol.h"

@class MCPayment;
@class MCSharedBill;
@class MCPerson;
@class MCPaymentViewController;
@class MCTwoLabelsTitleView;

typedef NS_ENUM(NSUInteger, MCMoneyValueFieldDismissStatus) {
    MCMoneyValueFieldDismissStatusCancelIsPressed,
    MCMoneyValueFieldDismissStatusDoneIsPressed,
    MCMoneyValueFieldDismissStatusOtherTextFieldSelected,
    MCMoneyValueFieldDismissStatusBackgroundTapped,
    MCMoneyValueFieldDismissStatusCurrencySelectionTapped
};

@protocol MCPaymentViewControllerDelegate <NSObject>

- (void)removePayment:(MCPayment *)payment fromPaymentViewController:(MCPaymentViewController *)pvc;

@end

@interface MCPaymentViewController : UITableViewController <NSFetchedResultsControllerDelegate, MCThisPaymentProtocol, MCPathComponentsToOpenProtocol>

@property (nonatomic, strong) MCPayment *thisPayment;
@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, readonly) BOOL didSomethingChange;
@property (nonatomic, readonly) BOOL isNew;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSArray *pathComponentsToOpen;

- (IBAction)mainCancelButtonPressed:(id)sender;
- (IBAction)mainDoneButtonPressed:(id)sender;

@end
