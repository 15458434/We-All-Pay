//
//  MCSelectEmailAddressTableViewController_iPad.h
//  We all pay
//
//  Created by Mark Cornelisse on 16-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import UIKit;
#import "MCThisPersonProtocol.h"
#import "MCDismissMeBlockProtocol.h"

@class MCPerson;

@interface MCSelectEmailAddressTableViewController_iPad : UITableViewController <MCThisPersonProtocol, MCDismissMeBlockProtocol>
{
    NSArray *_allEmailAddresses;
}

@property (strong, nonatomic) MCPerson *thisPerson;
@property (strong, nonatomic) void (^dismissMe)();

// Only accessible in the backgroundthread.
@property (strong, nonatomic) MCPerson *writableThisPerson;

@end
