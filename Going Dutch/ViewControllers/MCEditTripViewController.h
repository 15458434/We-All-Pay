//
//  MCPeopleViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 25-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import CoreData;
@import AddressBookUI;
@import NotificationCenter;
#import "MCPersonViewController.h"

#import "MCTonightsBillTransfer.h"
#import "MCThisPersonProtocol.h"
#import "MCIndexProtocol.h"
#import "MCIsEditingProtocol.h"

@class MCPeople;
@class MCSharedBill;
@class MCTwoLabelsTitleView;
@class MCTableEmptyMessage;

@interface MCEditTripViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, MCPersonViewChangeDelegate, MCTonightsBillTransfer>

@property (nonatomic) BOOL isInitAsNew;

@property (nonatomic, weak) id<MCIsEditingProtocol> myParent;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, strong) MCSharedBill *writableTonightsBill;
@property (nonatomic, copy) void (^dismissOnDone)(void);
@property (nonatomic, copy) void (^dismissOnCancel)(void);
@property (nonatomic, readonly) BOOL didSomethingChange;

@property (nonatomic) NSInteger index;

- (IBAction)addressBookButton:(id)sender;
- (IBAction)addPersonButton:(id)sender;

@end
