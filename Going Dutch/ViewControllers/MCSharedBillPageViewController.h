//
//  MCPageViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 22-12-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCSharedBill;

@interface MCSharedBillPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    __weak IBOutlet UIPageControl *pageViewIndicator;
}

@property (nonatomic, strong) MCSharedBill *tonightsBill;

@end
