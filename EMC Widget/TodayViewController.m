//
//  TodayViewController.m
//  EMC Widget
//
//  Created by Mark Cornelisse on 23/10/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler {
    // Update your data and prepare for a snapshot. Call completion handler when you are done
    // with NoData if nothing has changed or NewData if there is new data since the last
    // time we called you
    completionHandler(NCUpdateResultNoData);
}

@end

