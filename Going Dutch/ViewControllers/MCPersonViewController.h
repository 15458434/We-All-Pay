//
//  MCPersonViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 31-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import CoreData;

#import "MCGenericMediumAdBannerViewController.h"

#import "We_all_pay-Swift.h"

#import "MCTonightsBillTransfer.h"

@class MCPerson;
@class MCSharedBill;
@class MCTwoLabelsTitleView;

__attribute__((objc_subclassing_restricted))
@interface MCPersonViewController : MCGenericMediumAdBannerViewController <MCTonightsBillTransfer, MCThisPersonProtocol>

// Only accessible on the mainThread.
@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, strong) MCPerson *thisPerson;
@property (nonatomic) BOOL isNew;

// Only accessible on the background thread.
@property (nonatomic, strong) MCSharedBill *writableTonightsBill;
@property (nonatomic, strong) MCPerson *writableThisPerson;

@end
