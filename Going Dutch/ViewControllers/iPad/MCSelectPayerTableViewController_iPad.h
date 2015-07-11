//
//  MCSelectPayerTableViewController_iPad.h
//  We all pay
//
//  Created by Mark Cornelisse on 07-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import CoreData;

#import "MCTonightsBillTransfer.h"
#import "MCThisPaymentProtocol.h"

@class MCSharedBill;
@class MCPayment;

@interface MCSelectPayerTableViewController_iPad : UITableViewController <MCTonightsBillTransfer, MCThisPaymentProtocol>
{
    NSArray *people;
}

@property (strong, nonatomic) MCSharedBill *tonightsBill;
@property (strong, nonatomic) MCSharedBill *writableTonightsBill;
@property (strong, nonatomic) MCPayment *thisPayment;
@property (strong, nonatomic) void (^dismissMe)();

@end
