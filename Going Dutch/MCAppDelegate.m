//
//  MCAppDelegate.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCAppDelegate.h"
#import "MCAllTripsTableViewController.h"
#import "MCPaymentViewController.h"

#import "MCWeAllPayStoreController.h"
#import "MCStoreInterface.h"
#import "XRCurrencyStoreController.h"

#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"
#import "MCPayment+addons.h"

@implementation MCAppDelegate

#pragma mark - New in this class

//- (void)setupGoogleAnalytics
//{
    // Optional: automatically send uncaught exceptions to Google Analytics.
//    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
//    [GAI sharedInstance].dispatchInterval = 120;
    
    // Optional: set Logger to VERBOSE for debug information.
//    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
    
    // Initialize tracker. Replace with your tracking ID.
//    [[GAI sharedInstance] trackerWithTrackingId:@"UA-50304745-1"];
    
    // Tracker for development environment.
//    [[GAI sharedInstance] trackerWithTrackingId:@"UA-50304745-2"];
    
    // Get opt-in value
    // Get user preference
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    BOOL optInValue = [defaults boolForKey:@"googleAnalyticsOptIn"];
//    BOOL success = [defaults synchronize];
//    if (!success) {
//        NSLog(@"Unable to write userDefaults.");
//    }
    
    // Set to YES if during test versions.
//    [[GAI sharedInstance] setDryRun:!optInValue];
//}

- (void)startGoogleAnalyticsSession
{
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAISessionControl value:@"start"];
}

- (void)stopGoogleAnalyticsSession
{
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAISessionControl value:@"stop"];
//    [tracker set:kGAIScreenName value:@"Leaving"];
//    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
//    [[GAI sharedInstance] dispatch];
}

- (void)getAppSettings
{
    // Set the application defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = @{ @"googleAnalyticsOptIn" : @YES};
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];
}

- (void)executeOnlyOnceDuringStartup
{
    [self getAppSettings];
//    [self setupGoogleAnalytics];
//    [self startGoogleAnalyticsSession];
//    [TestFlight takeOff:@"f2224673-b632-44ae-8feb-3c1cfe59e1f5"];
    // Override point for customization after application launch.
    NSLog(@"%@ running iOS %@", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion]);
    NSLog(@"I dedicate this program to Ilse Béguin, the most wonderful woman in the world who brought herself into my life, when I was developing the first version App.");
#if DEBUG
    NSLocale *locale = [NSLocale currentLocale];
    NSString *languageCode = [locale objectForKey:NSLocaleLanguageCode];
    NSLog(@"The current language code is: %@", languageCode);
#endif
    // Set colors throughout the App.
    [[UINavigationBar appearance] setBarTintColor:[MCColors getNavigationColor]];
    [[UINavigationBar appearance] setTintColor:[MCColors getButtonColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [[UIButton appearance] setTitleColor:[MCColors getButtonColor] forState:UIControlStateNormal];
    [[UIButton appearance] setTitleColor:[MCColors getButtonDisabledColor] forState:UIControlStateDisabled];
    [[UIBarButtonItem appearance] setTintColor:[MCColors getButtonColor]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIButton appearanceWhenContainedIn:[UITableViewCell class], nil] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSArray *pathComponents = url.pathComponents;
    if (pathComponents.count != 3) {
        return NO;
    }
    NSString *billID = pathComponents[1];
    NSString *nextPayerID = pathComponents[2];
    
    // Verify existense of tonightsBill
    MCSharedBill *tonightsBill = [MCSharedBill fetchSharedBillWithUniqueId:billID inContext:[[MCWeAllPayStoreController defaultStore] mainThreadContext] ];
    if (!tonightsBill) {
        NSLog(@"Unable to open this event.");
        return NO;
    }
    // Verify existendse of payer on tonightsBill
    MCPerson *nextPayer = [tonightsBill fetchPersonWithUniqueID:nextPayerID];
    if (!nextPayer) {
        NSLog(@"Unable to find specified person");
        return NO;
    }
    // Navigate to the add payment screen.
    NSArray *pathDuringOpening = @[tonightsBill, nextPayer];
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    [navController popToRootViewControllerAnimated:NO];
    
    // open add payment
    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
    UINavigationController *navPaymentViewController = [storyboard instantiateViewControllerWithIdentifier:@"navPaymentViewController"];
    MCPaymentViewController *paymentViewController = (MCPaymentViewController *)[navPaymentViewController viewControllers][0];
    paymentViewController.pathComponentsToOpen = pathDuringOpening;
    paymentViewController.tonightsBill = tonightsBill;
    [navController presentViewController:navPaymentViewController animated:YES completion:nil];
    // open tonightsBill
    UIViewController *allTripsViewController = navController.viewControllers[0];
    [allTripsViewController performSegueWithIdentifier:@"openTonightsBill" sender:pathDuringOpening];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return NO;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    dispatch_once(&executeOnlyOnce, ^{
        [self executeOnlyOnceDuringStartup];
        [MCWeAllPayStoreController prepareCurrencyStoreIfNecessary];
        [[MCWeAllPayStoreController defaultStore] openStore:nil];
        
    });
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    dispatch_once(&executeOnlyOnce, ^{
        [self executeOnlyOnceDuringStartup];
        [MCWeAllPayStoreController prepareCurrencyStoreIfNecessary];
        [[MCWeAllPayStoreController defaultStore] openStore:nil];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [queue setQualityOfService:NSQualityOfServiceBackground];
            [queue addOperationWithBlock:^{
                [[XRCurrencyStoreController sharedStore] backgroundContext];
                [[XRCurrencyStoreController sharedStore] mainQueueContext];
#if DEBUG
                NSLog(@"Done creating contexts for XRCurrencyController on iOS 8");
#endif
            }];
        } else {
            dispatch_queue_t someBackgroundQueue = dispatch_queue_create("InitiateBackGroundContext for XRCurrencyStoreController", NULL);
            dispatch_async(someBackgroundQueue, ^{
                [[XRCurrencyStoreController sharedStore] backgroundContext];
                [[XRCurrencyStoreController sharedStore] mainQueueContext];
#if DEBUG
                NSLog(@"Done creating contexts for XRCurrencyController on iOS 7");
#endif
            });
        }
    });
    [[MCStoreInterface defaultStoreInterface] validateProductIdentifiers];
    
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
    [[MCWeAllPayStoreController defaultStore] savebackgroundContext];
//    [self stopGoogleAnalyticsSession];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [self startGoogleAnalyticsSession];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[MCWeAllPayStoreController defaultStore] closeDocument];
//    [[GAI sharedInstance] dispatch];
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Start views" object:nil];
}

- (IBAction)giveFeedBackPressed:(id)sender {
}

- (IBAction)tweetThankYouPressed:(id)sender {
}

- (IBAction)reverseConverstionPressed:(id)sender {
}
@end
