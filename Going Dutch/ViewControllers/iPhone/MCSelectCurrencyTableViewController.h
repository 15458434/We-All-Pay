//
//  MCSelectCurrencyTableViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 28/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import CoreData;
#import "MCDismissMeBlockProtocol.h"
#import "MCThisPaymentProtocol.h"

@class MCPayment;

@interface MCSelectCurrencyTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, MCThisPaymentProtocol, MCDismissMeBlockProtocol>

@property (nonatomic, strong) MCPayment *thisPayment;
@property (nonatomic, strong) void (^dismissMe)();

@end
