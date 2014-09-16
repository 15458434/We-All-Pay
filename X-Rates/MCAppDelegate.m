//
//  MCAppDelegate.m
//  X-Rates
//
//  Created by Mark Cornelisse on 22-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCAppDelegate.h"
#import "MultipleCurrencyInterface.h"

@interface MCAppDelegate ()

@property (nonatomic, strong) MultipleCurrencyInterface *multipleCurrencyInterfaceController;

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

- (IBAction)newWindowPressed:(id)sender
{
    [_singleCurrencyWindow makeKeyAndOrderFront:self];
}

- (IBAction)multipleCurrencyWindowPressed:(id)sender
{
    // TODO: Create this function.
    if (!_multipleCurrencyInterfaceController) {
        _multipleCurrencyInterfaceController = [[MultipleCurrencyInterface alloc] init];
    }
    [_multipleCurrencyInterfaceController showWindow:self];
}

- (IBAction)closeKeyWindow:(id)sender
{
    NSWindow *keyWindow = [[NSApplication sharedApplication] keyWindow];
    [keyWindow performClose:self];
}


#pragma mark - Inherited from super

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    [_singleCurrencyWindow makeKeyAndOrderFront:self];
    return NO;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{

}

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
