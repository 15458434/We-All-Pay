//
//  MCSharedBillsViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import CoreData;
@import Social;

@class MCWeAllPayStoreController;
@class MCTableEmptyMessage;

@interface MCAllTripsTableViewController : UITableViewController < NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) MCTableEmptyMessage *emptyMessage;
@property (nonatomic, strong) NSDateFormatter *df;

@end
