//
//  MCAppDelegate.h
//  X-Rates
//
//  Created by Mark Cornelisse on 22-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Cocoa;

@class MCMainXRatesViewController;

@interface MCAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet MCMainXRatesViewController *masterViewController;

@end
