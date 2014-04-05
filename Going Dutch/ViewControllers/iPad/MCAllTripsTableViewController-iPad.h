//
//  MCAllTripsTableViewController-iPad.h
//  We all pay
//
//  Created by Mark Cornelisse on 31-03-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MCAllTripsTableViewController_iPad : UITableViewController <NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *dataController;
    NSDateFormatter *df;
}

- (void)performFetchAndReloadTableView:(NSNotification *)notification;



@end
