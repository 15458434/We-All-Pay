//
//  MCPersonViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 31-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import CoreData;

#import "We_all_pay-Swift.h"

#import "MCTonightsBillTransfer.h"

@class MCPerson;
@class MCSharedBill;
@class MCTwoLabelsTitleView;

@interface MCPersonViewController : UITableViewController <MCTonightsBillTransfer, MCThisPersonProtocol>

// Only accessible on the mainThread.
@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, strong) MCPerson *thisPerson;
@property (nonatomic) BOOL isNew;

// Only accessible on the background thread.
@property (nonatomic, strong) MCSharedBill *writableTonightsBill;
@property (nonatomic, strong) MCPerson *writableThisPerson;

@end
