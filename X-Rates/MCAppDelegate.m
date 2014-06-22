//
//  MCAppDelegate.m
//  X-Rates
//
//  Created by Mark Cornelisse on 22-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCAppDelegate.h"

#import "MCMainXRatesViewController.h"

@implementation MCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _masterViewController = [[MCMainXRatesViewController alloc] init];
    [[_window contentView] addSubview:[_masterViewController view]];
    [[_masterViewController view] setFrame:[((NSView *)[_window contentView]) bounds]];
}

@end
