//
//  MCAppDelegate.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCAppDelegate.h"
#import "MCAllTripsTableViewController.h"
#import "MCWeAllPayStoreController.h"
#import "TestFlight.h"

@implementation MCAppDelegate

#pragma mark - New in this class

- (void)setupGoogleAnalytics
{
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 120;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-50304745-1"];
    
    // Tracker for development environment.
//    [[GAI sharedInstance] trackerWithTrackingId:@"UA-50304745-2"];
    
    // Set to YES if during test versions.
    [[GAI sharedInstance] setDryRun:NO];
}

- (void)startGoogleAnalyticsSession
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAISessionControl value:@"start"];
}

- (void)stopGoogleAnalyticsSession
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAISessionControl value:@"stop"];
    [[GAI sharedInstance] dispatch];
}

- (void)executeOnlyOnceDuringStartup
{
    [self setupGoogleAnalytics];
    [self startGoogleAnalyticsSession];
//    [TestFlight takeOff:@"f2224673-b632-44ae-8feb-3c1cfe59e1f5"];
    // Override point for customization after application launch.
    NSLog(@"%@", [[UIDevice currentDevice] model]);
    NSLog(@"I dedicate this program to Ilse Béguin, the most wonderful woman in the world who brought herself into my life, when I was developing this App.");
    
    // Set colors throughout the App.
    [[UINavigationBar appearance] setBarTintColor:[MCColors getNavigationColor]];
    [[UINavigationBar appearance] setTintColor:[MCColors getButtonColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [[UIButton appearance] setTitleColor:[MCColors getButtonColor] forState:UIControlStateNormal];
    [[UIButton appearance] setTitleColor:[MCColors getButtonDisabledColor] forState:UIControlStateDisabled];
    [[UIBarButtonItem appearance] setTintColor:[MCColors getButtonColor]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Set the background color in the peoplepicker.
    [[UISearchBar appearance] setBarTintColor:[MCColors getbackgroundColor]];
    
    // Set the color of the cancelButton of the search bar
    UIBarButtonItem *addressBookSearchBarCancelButton = [UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil];
    UIColor *addressBookSearchBarCancelButtonColor = [MCColors getButtonColor];
    NSMutableDictionary *colorDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            addressBookSearchBarCancelButtonColor,
                                            NSForegroundColorAttributeName,
                                            nil];
    [colorDictionary setObject:addressBookSearchBarCancelButtonColor forKey:NSForegroundColorAttributeName];
    [addressBookSearchBarCancelButton setTitleTextAttributes:colorDictionary forState:UIControlStateNormal];
    
    // Set the sectionIndex color in the people picker
    [[UITableView appearance] setSectionIndexColor:[MCColors getButtonColor]];
    
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    
    /*
    // Set the sectionColor
    UIView *sectionViewInPicker = [UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], [ABPeoplePickerNavigationController class], nil];
    [sectionViewInPicker setBackgroundColor:[MCColors getbackgroundColor]];
    
    // Set the labelColor of the section in peoplepicker
    UILabel *pickerLabels = [UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil];
    [pickerLabels setTextColor:[MCColors getEmptyMessageTextColor]];
     */
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return NO;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    dispatch_once(&executeOnlyOnce, ^{
        [self executeOnlyOnceDuringStartup];
    });
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    dispatch_once(&executeOnlyOnce, ^{
        [self executeOnlyOnceDuringStartup];
    });
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    [[MCWeAllPayStoreController defaultStore] saveStore];
    [self stopGoogleAnalyticsSession];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self startGoogleAnalyticsSession];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[MCWeAllPayStoreController defaultStore] closeDocument];
    [[GAI sharedInstance] dispatch];
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Start views" object:nil];
}

@end
