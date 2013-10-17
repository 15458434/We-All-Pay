//
//  MCEmailAddressesViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 17-10-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCCoreDataTableViewController.h"

@class MCPerson;

@interface MCEmailAddressesViewController : MCCoreDataTableViewController

@property (nonatomic, readonly) MCPerson *thisPerson;

- (id)initWithPerson:(MCPerson *)person;

@end
