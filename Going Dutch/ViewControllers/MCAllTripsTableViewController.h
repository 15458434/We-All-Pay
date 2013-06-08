//
//  MCSharedBillsViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCPaymentViewController.h"

@class MCAllTripsStore;
@class MCTwoLabelsTitleView;

@interface MCAllTripsTableViewController : UITableViewController <MCPaymentViewControllerDelegate>
{
    __strong IBOutlet MCTwoLabelsTitleView *titleView;
    
    NSDateFormatter *df;
}

- (void)addTrip:(id)sender;

@end
