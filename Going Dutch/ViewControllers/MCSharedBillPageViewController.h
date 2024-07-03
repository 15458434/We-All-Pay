//
//  MCPageViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 22-12-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import Foundation;
@import UIKit;

#import "MCTonightsBillTransfer.h"
#import "We_all_pay-Swift.h"

@class MCSharedBill;

@class MCEditTripViewController;
@class MCPaymentsTableViewController;
@class MCSharedBillMainViewController;

@protocol MCTonightsBillTitleDelegate <NSObject>

- (UILabel *)titleLabel;
- (void)setTitleLabel:(UILabel *)titleLabel;

@end

__attribute__((objc_subclassing_restricted))
@interface MCSharedBillPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) MCEventModel *eventModel;
@property (nonatomic, strong) MCToggleModel *isEditingModel;

@property (weak, nonatomic) MCSharedBillMainViewController *mainViewController;
@property (nonatomic, strong) MCPaymentsTableViewController *sharedBillTableViewController;
@property (nonatomic, strong) MCEditTripViewController *editTripTableViewController;

- (void)peopleOrPaymentsSelectionControlTapped:(id)sender;

@end
