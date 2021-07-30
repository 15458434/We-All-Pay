//
//  MCSharedBillPeoplePresentTableViewController-iPad.h
//  We all pay
//
//  Created by Mark Cornelisse on 02-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import CoreData;

#import "MCTonightsBillTransfer.h"

@class MCSharedBill;
@class MCTableEmptyMessage;

__attribute__((objc_subclassing_restricted))
@interface MCSharedBillPeoplePresentTableViewController_iPad : UITableViewController <NSFetchedResultsControllerDelegate, MCTonightsBillTransfer>

@property (nonatomic, strong) MCTableEmptyMessage *emptyMessage;

@property (strong, nonatomic) MCSharedBill *tonightsBill;
@property (strong, nonatomic) MCSharedBill *writableTonightsBill;

@end
