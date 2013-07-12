//
//  MCSharedBillsViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MCPaymentViewController.h"

@class MCWeAllPayStoreController;
@class MCTwoLabelsTitleView;

@interface MCAllTripsTableViewController : UITableViewController <MCPaymentViewControllerDelegate, NSFetchedResultsControllerDelegate>
{
    __strong IBOutlet MCTwoLabelsTitleView *titleView;
    
    NSDateFormatter *df;
    NSFetchedResultsController *dataController;
}

- (void)addTrip:(id)sender;

@end
