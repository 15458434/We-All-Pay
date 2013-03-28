//
//  MCSharedBillsViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCPaymentViewController.h"

@class MCAllTripsStore;

@interface MCAllTripsTableViewController : UITableViewController <MCPaymentViewControllerDelegate>

- (void)addTrip:(id)sender;
- (void)reloadButton:(id)sender;

@end
