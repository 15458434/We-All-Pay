//
//  MCSharedBillsViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <Social/Social.h>

@class MCWeAllPayStoreController;
@class MCTwoLabelsTitleView;
@class MCTableEmptyMessage;

@interface MCAllTripsTableViewController : UITableViewController < NSFetchedResultsControllerDelegate>
{
    __strong IBOutlet MCTwoLabelsTitleView *titleView;
    MCTableEmptyMessage *emptyMessage;
    
    NSDateFormatter *df;
    NSFetchedResultsController *dataController;
}

- (IBAction)tellAFriendAboutWeAllPay:(id)sender;


@end
