//
//  MCPreferencesWindowController.m
//  We all pay
//
//  Created by Mark Cornelisse on 10/08/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCPreferencesWindowController.h"

NSString * const MCCountlyOptIn = @"MCCountlyOptin";

@interface MCPreferencesWindowController ()

@property (weak) IBOutlet NSButton *analyticsOptIntCheckBox;

@end

@implementation MCPreferencesWindowController

#pragma mark - Class methods

+ (BOOL)analyticsOptIn
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *optin = [userDefaults objectForKey:MCCountlyOptIn];
    NSLog(@"Preference read: %@", optin);
    return optin.boolValue;
}

+ (void)setAnalyticsOptin:(BOOL)newValue
{
    NSNumber *newOptInValue = [NSNumber numberWithBool:newValue];
    [[NSUserDefaults standardUserDefaults] setObject:newOptInValue forKey:MCCountlyOptIn];
    if ([[NSUserDefaults standardUserDefaults] synchronize]) {
        NSLog(@"Preference stored: %@", newOptInValue);
    } else {
        NSLog(@"Preference not stored: %@", newOptInValue);
    }
}

+ (void)registerDefaultPreferences
{
    // execute once.
    static dispatch_once_t oneShot;
    dispatch_once(&oneShot, ^{
        NSDictionary *defaultValues = @{MCCountlyOptIn: @YES};
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
        if ([[NSUserDefaults standardUserDefaults] synchronize]) {
            NSLog(@"Defaults registered.");
        }
    });
}

#pragma mark - Actions

- (IBAction)storeAnalyticsOptin:(id)sender
{
    // Change analytics Opt in
    [MCPreferencesWindowController setAnalyticsOptin:[_analyticsOptIntCheckBox state]];
}

#pragma mark - Inherited from super

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [_analyticsOptIntCheckBox setState:[MCPreferencesWindowController analyticsOptIn]];
}

@end
