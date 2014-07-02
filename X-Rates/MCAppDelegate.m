//
//  MCAppDelegate.m
//  X-Rates
//
//  Created by Mark Cornelisse on 22-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCAppDelegate.h"

@implementation MCAppDelegate

#pragma mark - Actions

- (void)giveFeedBackPressed:(id)sender
{
    NSSharingService *service = [NSSharingService sharingServiceNamed:NSSharingServiceNameComposeEmail];
    service.delegate = self;
    service.recipients = @[@"support@markcornelisse.nl"];
    service.subject = [ NSString stringWithFormat:@"Feedback on X-Rates"];
    NSString *body = @"Dear Mark, \n\n";
    NSArray *shareItems = @[body];
    [service performWithItems:shareItems];
}

- (void)tweetThankYouPressed:(id)sender
{
    NSSharingService *service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
    [service setDelegate:self];
    NSString *tweet = @"@MarkCornelisse Thank you for creating X-Rates. #osx #app";
    [service performWithItems:@[tweet]];
}

#pragma mark - Inherited from super

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
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
