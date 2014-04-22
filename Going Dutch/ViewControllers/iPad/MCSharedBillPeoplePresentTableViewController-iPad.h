//
//  MCSharedBillPeoplePresentTableViewController-iPad.h
//  We all pay
//
//  Created by Mark Cornelisse on 02-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "MCTonightsBillTransfer.h"
#import "MCThisPersonProtocol.h"

@class MCSharedBill;
@class MCTableEmptyMessage_iPad;

@interface MCSharedBillPeoplePresentTableViewController_iPad : UITableViewController <NSFetchedResultsControllerDelegate, MCTonightsBillGet>
{
    MCTableEmptyMessage_iPad *emptyMessage;
    
    NSFetchedResultsController *dataController;
}

@property (strong, nonatomic) MCSharedBill *tonightsBill;

@end
