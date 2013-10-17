//
//  MCCoreDataTableViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 17-10-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MCCoreDataTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *dataController;
}

@property (nonatomic, strong) UIManagedDocument *myDocument;

- (void)performFetch;


@end
