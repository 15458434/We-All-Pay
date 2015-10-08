//
//  MCPageViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 22-12-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import UIKit;

#import "MCTonightsBillTransfer.h"
#import "MCIsEditingProtocol.h"

@class MCSharedBill;

@class MCEditTripViewController;
@class MCSharedBillTableViewController;

@protocol MCTonightsBillTitleDelegate <NSObject>

- (UILabel *)titleLabel;
- (void)setTitleLabel:(UILabel *)titleLabel;

@end

@interface MCSharedBillPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIAlertViewDelegate, MCTonightsBillTitleDelegate, MCIsEditingProtocol>
{
    NSUInteger newPageNumber;
}
@property (nonatomic, strong) MCSharedBillTableViewController *sharedBillTableViewController;
@property (nonatomic, strong) MCEditTripViewController *editTripTableViewController;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, strong) MCSharedBill *writableTonightsBill;

- (BOOL)toggleEditTableView:(id)sender;

- (void)pageControlTapped:(id)sender;

- (UIPageControl *)pageViewIndicator;

@end
