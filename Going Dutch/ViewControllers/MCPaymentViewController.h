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

#import "MCGenericAdBannerTableViewController.h"

#import "MCPathComponentsToOpenProtocol.h"

#import "We_all_pay-Swift.h"

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

__attribute__((objc_subclassing_restricted))
@interface MCPaymentViewController : MCGenericAdBannerTableViewController <NSFetchedResultsControllerDelegate, MCPathComponentsToOpenProtocol>

@property (nonatomic, readonly) BOOL didSomethingChange;
@property (nonatomic, readonly) BOOL isNew;
@property (nonatomic, weak) id delegate;

- (IBAction)mainCancelButtonPressed:(id)sender;
- (IBAction)mainDoneButtonPressed:(id)sender;

/// Creates a new payment from this event to be displayed on this ViewController
/// @param event Sets the event to create the payment to be displayed.
- (void)prepareForUseWithEvent:(MCSharedBill *)event;

/// Sets the payment to be displayed on this View Controller
/// @param payment Sets the payment to display.
- (void)prepareForUseWithPayment:(MCPayment *)payment;

@end
