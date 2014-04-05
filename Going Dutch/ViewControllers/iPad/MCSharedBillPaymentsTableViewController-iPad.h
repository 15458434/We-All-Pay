//
//  MCSharedBillPaymentsTableViewController-iPad.h
//  We all pay
//
//  Created by Mark Cornelisse on 02-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "MCTonightsBillTransfer.h"

@class MCSharedBill;

@interface MCSharedBillPaymentsTableViewController_iPad : UITableViewController <NSFetchedResultsControllerDelegate, MCTonightsBillGet>
{
    NSFetchedResultsController *dataController;
}

@property (strong, nonatomic) MCSharedBill *tonightsBill;

@end
