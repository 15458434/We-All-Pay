//
//  MCSharedBillTableViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCSharedBill;
@class MCAllTripsTableViewController;

@interface MCSharedBillTableViewController : UITableViewController
{
    MCSharedBill *tonightsBill;
}

- (id)initWithSharedBill:(MCSharedBill *)tBill;
- (void)addPayment:(id)sender;

@property (nonatomic, strong) MCSharedBill *tonightsBill;

@end
