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
@class MCTableEmptyMessage_iPad;

@interface MCSharedBillPaymentsTableViewController_iPad : UITableViewController <NSFetchedResultsControllerDelegate, MCTonightsBillTransfer>
{
    MCTableEmptyMessage_iPad *emptyMessage;
}

@property (strong, nonatomic) MCSharedBill *tonightsBill;
@property (strong, nonatomic) MCSharedBill *writableTonightsBill;

@end
