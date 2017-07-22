//
//  MCSharedBillMainViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 28-03-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import UIKit;

#import "MCTonightsBillTransfer.h"
#import "MCCurrentViewDelegate.h"
#import "MCPathComponentsToOpenProtocol.h"

#import "UIViewController+WeAllPayStore.h"

@class MCSharedBill;

@interface MCSharedBillMainViewController : UIViewController <MCTonightsBillTransfer, MCCurrentViewDelegate, MCPathComponentsToOpenProtocol>

@property (nonatomic) MCSharedBillViewSelector currentView;
@property (strong, nonatomic) MCSharedBill *tonightsBill;
@property (nonatomic, strong) MCSharedBill *writableTonightsBill;

@property (strong, nonatomic) NSArray *pathComponentsToOpen;

@property (weak, nonatomic) IBOutlet UISegmentedControl *peopleOrPaymentsSelectionControl;

@end
