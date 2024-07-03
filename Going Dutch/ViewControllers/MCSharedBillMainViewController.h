//
//  MCSharedBillMainViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 28-03-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import CoreData;
#import "MCGenericAdBannerViewController.h"

#import "MCTonightsBillTransfer.h"
#import "MCCurrentViewDelegate.h"

#import "UIViewController+WeAllPayStore.h"

#import "We_all_pay-Swift.h"

@class MCSharedBill;

__attribute__((objc_subclassing_restricted))
@interface MCSharedBillMainViewController : MCGenericAdBannerViewController <MCCurrentViewDelegate, MCPathComponentsToOpenProtocol>

@property (nonatomic) MCSharedBillViewSelector currentView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *peopleOrPaymentsSelectionControl;

- (void)updateEventWithObjectID:(NSManagedObjectID *)objectID __deprecated;
- (void)prepareForUseWithEventModel:(MCEventModel *)model;

@end
