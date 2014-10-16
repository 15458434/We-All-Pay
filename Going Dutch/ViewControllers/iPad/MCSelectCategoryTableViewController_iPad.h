//
//  MCSelectCategoryTableViewController_iPad.h
//  We all pay
//
//  Created by Mark Cornelisse on 16/10/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import UIKit;

#include "MCThisPaymentProtocol.h"
#include "MCDismissMeBlockProtocol.h"

@class MCPayment;

@interface MCSelectCategoryTableViewController_iPad : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, MCThisPaymentProtocol, MCDismissMeBlockProtocol>

@property (nonatomic, strong) MCPayment *thisPayment;
@property (strong, nonatomic) void (^dismissMe)();


@end
