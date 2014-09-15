//
//  MCCurrentViewDelegate.h
//  We all pay
//
//  Created by Mark Cornelisse on 31-03-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MCSharedBillViewSelector) {
    MCSelectSharedBillTableView,
    MCSelectEditTripTableView
};

@protocol MCCurrentViewDelegate <NSObject>

- (MCSharedBillViewSelector) currentView;
- (void) setCurrentView:(MCSharedBillViewSelector)currentView;

@end
