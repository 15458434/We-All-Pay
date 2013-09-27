//
//  MCReturnPaymentViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 07-02-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@class MCSharedBill;
@class MCTwoLabelsTitleView;

@interface MCReturnPaymentViewController : UITableViewController
{
    MCSharedBill *tonightsBill;
    NSMutableArray *paymentsAfterwards;
    
    __strong IBOutlet MCTwoLabelsTitleView *twoLabelTitleView;
}

- (id)initWithBill:(MCSharedBill *)thisBill;

@property (nonatomic, strong) MCSharedBill *tonightsBill;

@end
