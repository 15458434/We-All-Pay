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

@class MCPerson;
@class MCTwoLabelsTitleView;

__attribute__((objc_subclassing_restricted))
@interface MCPersonViewController : MCGenericMediumAdBannerViewController

@property (nonatomic) BOOL isNew;

- (void)updateWithPerson:(MCPerson *)person;

@end
