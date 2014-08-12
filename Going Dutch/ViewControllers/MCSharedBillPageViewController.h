//
//  MCPageViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 22-12-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCTonightsBillTransfer.h"

@class MCSharedBill;

@class MCEditTripViewController;
@class MCSharedBillTableViewController;

@protocol MCTonightsBillTitleDelegate <NSObject>

- (UILabel *)titleLabel;
- (void)setTitleLabel:(UILabel *)titleLabel;

@end

@interface MCSharedBillPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIAlertViewDelegate, MCTonightsBillTitleDelegate>
{
    MCSharedBillTableViewController *sharedBillTableViewController;
    MCEditTripViewController *editTripTableViewController;
    
    //__weak IBOutlet UIPageControl *pageViewIndicator;
    NSUInteger newPageNumber;
}

// @property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, strong) MCSharedBill *writableTonightsBill;

- (IBAction)toggleEdit:(id)sender;
- (IBAction)solveBill:(id)sender;

- (void)shareBill:(id)sender;
- (void)sendMail:(id)sender;

- (void)openMailView:(id)sender;

- (UIPageControl *)pageViewIndicator;

//- (void)writeableTonightsBillIsCreated:(NSNotification *)notification;

@end
