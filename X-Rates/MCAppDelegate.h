//
//  MCAppDelegate.h
//  X-Rates
//
//  Created by Mark Cornelisse on 22-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Cocoa;

@interface MCAppDelegate : NSObject <NSApplicationDelegate, NSSharingServiceDelegate>

@property (assign) IBOutlet NSWindow *singleCurrencyWindow;

- (IBAction)giveFeedBackPressed:(id)sender;
- (IBAction)tweetThankYouPressed:(id)sender;


@end
