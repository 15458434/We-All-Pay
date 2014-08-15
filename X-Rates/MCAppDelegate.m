//
//  MCAppDelegate.m
//  X-Rates
//
//  Created by Mark Cornelisse on 22-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCAppDelegate.h"
#import "Countly.h"
#import "MCPreferencesWindowController.h"

@interface MCAppDelegate ()

@property (nonatomic, strong) MCPreferencesWindowController *preferencesPanel;

@end

@implementation MCAppDelegate

#pragma mark - Actions

- (void)giveFeedBackPressed:(id)sender
{
    NSSharingService *service = [NSSharingService sharingServiceNamed:NSSharingServiceNameComposeEmail];
    service.delegate = self;
    service.recipients = @[@"support@markcornelisse.nl"];
    service.subject = [ NSString stringWithFormat:@"Feedback on EMC"];
    NSString *body = @"Dear Mark, \n\n";
    NSArray *shareItems = @[body];
    [service performWithItems:shareItems];
}

- (void)tweetThankYouPressed:(id)sender
{
    NSSharingService *service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
    [service setDelegate:self];
    NSString *tweet = @".@MarkCornelisse Thank you for creating EMC. #osx #app";
    [service performWithItems:@[tweet]];
}

- (IBAction)showPreferencesPanel:(id)sender
{
    // Show preference panel to the user.
    if (!_preferencesPanel) {
        _preferencesPanel = [[MCPreferencesWindowController alloc] initWithWindowNibName:@"MCPreferencesWindowController"];
    }
    [_preferencesPanel showWindow:self];
}

- (IBAction)newWindowPressed:(id)sender
{
    [_window makeKeyAndOrderFront:self];
}

#pragma mark - Inherited from super

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    [_window makeKeyAndOrderFront:self];
    return NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [MCPreferencesWindowController registerDefaultPreferences];
//    [[Countly sharedInstance] startOnCloudWithAppKey:@"b82580f508600a702d0eec03adb26319a8c2c1c9"];
}

#pragma mark - NSSharedServicesDelegate

- (void)sharingService:(NSSharingService *)sharingService didShareItems:(NSArray *)items
{
    NSLog(@"Sharing succesful");
}

- (void)sharingService:(NSSharingService *)sharingService didFailToShareItems:(NSArray *)items error:(NSError *)error
{
    NSLog(@"Sharing failed: %@", [error localizedDescription]);
}

@end
