//
//  MCPeopleViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 25-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import CoreData;
@import NotificationCenter;
@import WhoPayingUserDefaultsStoreInterface;

#import "MCPersonViewController.h"

#import "MCTonightsBillTransfer.h"
#import "MCIndexProtocol.h"
#import "MCIsEditingProtocol.h"

@class MCPeople;
@class MCSharedBill;
@class MCTwoLabelsTitleView;
@class MCTableEmptyMessage;

__attribute__((objc_subclassing_restricted))
@interface MCEditTripViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, MCTonightsBillTransfer>

@property (nonatomic) BOOL isInitAsNew;

@property (nonatomic, weak) id<MCIsEditingProtocol> myParent;
@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, strong) MCSharedBill *writableTonightsBill;
@property (nonatomic, readonly) BOOL didSomethingChange;

@property (nonatomic) NSInteger index;

@end
