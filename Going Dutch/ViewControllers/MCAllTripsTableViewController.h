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
@class MCTableEmptyMessage;

@interface MCAllTripsTableViewController : UITableViewController < NSFetchedResultsControllerDelegate>
{
    MCTableEmptyMessage *emptyMessage;
    
    NSDateFormatter *df;
}

@end
