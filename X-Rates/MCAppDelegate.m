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
    NSString *body = @"Dear Mark, \n\n";
    NSArray *shareItems=@[body];
    NSSharingService *service = [NSSharingService sharingServiceNamed:NSSharingServiceNameComposeEmail];
    service.delegate = self;
    service.recipients=@[@"support@markcornelisse.nl"];
    service.subject= [ NSString stringWithFormat:@"Feedback on X-Rates"];
    [service performWithItems:shareItems];
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
