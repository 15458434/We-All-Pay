//
//  MCAllTripsTableViewController-iPad.h
//  We all pay
//
//  Created by Mark Cornelisse on 31-03-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import CoreData;

@class MCTableEmptyMessage_iPad;
@class MCNotificationsInfoModel;

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
@interface MCAllTripsTableViewController_iPad : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) IBOutlet MCNotificationsInfoModel *notificationsStateModel;

@end

NS_ASSUME_NONNULL_END
