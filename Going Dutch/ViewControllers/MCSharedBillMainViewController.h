//
//  MCSharedBillMainViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 28-03-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCTitleViewDelegate.h"
#import "MCTonightsBillTransfer.h"

@class MCSharedBill;

@interface MCSharedBillMainViewController : UIViewController <MCTitleViewDelegate, MCTonightsBillPut, MCTonightsBillGet>
{
    
}

@property (strong, nonatomic) MCSharedBill *tonightsBill;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageIndicator;

@end
