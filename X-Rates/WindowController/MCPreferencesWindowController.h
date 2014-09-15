//
//  MCPreferencesWindowController.h
//  We all pay
//
//  Created by Mark Cornelisse on 10/08/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Cocoa;

extern NSString * const MCCountlyOptIn;

@interface MCPreferencesWindowController : NSWindowController

+ (void)registerDefaultPreferences;
+ (BOOL)analyticsOptIn;
+ (void)setAnalyticsOptin:(BOOL)newValue;

@end
