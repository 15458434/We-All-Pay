//
//  MCPageViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 22-12-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCSharedBill;

@protocol MCTonightsBillTitleDelegate <NSObject>

- (UILabel *)titleLabel;
- (void)setTitleLabel:(UILabel *)titleLabel;

@end

@interface MCSharedBillPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIAlertViewDelegate ,MCTonightsBillTitleDelegate>
{
    __weak IBOutlet UIPageControl *pageViewIndicator;
    NSUInteger newPageNumber;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic) BOOL isNew;

- (IBAction)toggleEdit:(id)sender;
- (IBAction)solveBill:(id)sender;

- (void)shareBill:(id)sender;
- (void)sendMail:(id)sender;

@end
