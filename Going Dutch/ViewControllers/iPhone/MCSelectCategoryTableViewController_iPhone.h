//
//  MCSelectCategoryTableViewController_iPhone.h
//  We all pay
//
//  Created by Mark Cornelisse on 16/10/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import UIKit;
#import "MCThisPaymentProtocol.h"

@class MCPayment;

@interface MCSelectCategoryTableViewController_iPhone : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, MCThisPaymentProtocol>

@property (nonatomic, strong) MCPayment *thisPayment;

@end
