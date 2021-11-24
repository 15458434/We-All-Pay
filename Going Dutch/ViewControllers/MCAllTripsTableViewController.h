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

#import "MCPathComponentsToOpenProtocol.h"

@class MCNotificationsInfoModel;
@class MCWeAllPayStoreController;
@class MCTableEmptyMessage;

__attribute__((objc_subclassing_restricted))
@interface MCAllTripsTableViewController : UITableViewController < NSFetchedResultsControllerDelegate, MCPathComponentsToOpenProtocol>

@property (nonatomic, strong) IBOutlet MCNotificationsInfoModel *notificationsStateModel;

@end
