//
//  MCSelectCurrencyTableViewController_iPad.h
//  We all pay
//
//  Created by Mark Cornelisse on 25/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import CoreData;

#import "MCThisPaymentProtocol.h"
#import "MCDismissMeBlockProtocol.h"

@class MCPayment;

@interface MCSelectCurrencyTableViewController_iPad : UITableViewController <NSFetchedResultsControllerDelegate, MCThisPaymentProtocol, MCDismissMeBlockProtocol>
{

}

@property (nonatomic, strong) MCPayment *thisPayment;
@property (strong, nonatomic) void (^dismissMe)();

@end
