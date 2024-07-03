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

#import "MCIndexProtocol.h"

@class MCPeople;
@class MCSharedBill;
@class MCTwoLabelsTitleView;
@class MCTableEmptyMessage;

__attribute__((objc_subclassing_restricted))
@interface MCEditTripViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate>

@property (nonatomic) BOOL isInitAsNew;

@property (nonatomic, strong) MCEventModel *eventModel;
@property (nonatomic, strong) MCToggleModel *isEditingModel;

@property (nonatomic, readonly) BOOL didSomethingChange;

@property (nonatomic) NSInteger index;

@end
