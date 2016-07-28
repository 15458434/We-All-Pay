//
//  MCAppDelegate.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import Firebase;

#import "MCAppDelegate.h"
#import "MCAllTripsTableViewController.h"
#import "MCPaymentViewController.h"

#import "MCAllTripsTableViewController-iPad.h"

#import "MCWeAllPayStoreController.h"

#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"
#import "MCPayment+addons.h"

#import "We_all_pay-Swift.h"

@interface MCAppDelegate ()

@property (nonatomic) dispatch_once_t executeOnlyOnce;

@end

@implementation MCAppDelegate

#pragma mark - New in this class

- (void)activateAnalytics
{
#if DEBUG
    [FIRApp configure];
#endif
}

- (void)removeOldCurrencyStore
{
    NSOperationQueue *myQueue = [[NSOperationQueue alloc] init];
    myQueue.name = @"removeOldCurrencyStore";
    [myQueue addOperationWithBlock:^{
        NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *directory = [documentsDirectory.path stringByAppendingPathComponent:@"XRCurrency"];
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:directory error:&error];
        if (!success || error) {
            // something went wrong
            NSLog(@"Error deleting XRCurrency: %@", error);
        }
    }];
}

- (void)checkToSeeIfThisPurchaseOriginatesFromiAd
{
    ADoriginate *adAttributionObject = [[ADoriginate alloc] init];
    if (adAttributionObject.fromiAd != nil) {
        // There is a value present.
        if (adAttributionObject.fromiAd.boolValue) {
            NSLog(@"We met with iAd.");
        } else {
            NSLog(@"We didn't met with iAd");
        }
    } else {
        [adAttributionObject fetchAttribution:^{
            if (adAttributionObject.fromiAd.boolValue) {
                NSLog(@"We met with iAd.");
            } else {
                NSLog(@"We didn't met with iAd");
            }
        }];
    }
}

- (void)executeOnlyOnceDuringStartup
{
    // Override point for customization after application launch.
    NSOperationQueue *someQueue = [[NSOperationQueue alloc] init];
    someQueue.name = @"Logging start";
    [someQueue addOperationWithBlock:^{
        NSLog(@"%@ running iOS %@", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion]);
        NSLog(@"I dedicate this program to Ilse Béguin, the most wonderful woman in the world who brought herself into my life, when I was developing the first version of this App.");
    }];
#if DEBUG
    NSLocale *locale = [NSLocale currentLocale];
    NSString *languageCode = [locale objectForKey:NSLocaleLanguageCode];
    NSLog(@"The current language code is: %@", languageCode);
#endif
    // Set colors throughout the App.
    [[UINavigationBar appearance] setBarTintColor:[Colors getNavigationColor]];
    [[UINavigationBar appearance] setTintColor:[Colors getButtonColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [[UIButton appearance] setTitleColor:[Colors getButtonColor] forState:UIControlStateNormal];
    [[UIButton appearance] setTitleColor:[Colors getButtonDisabledColor] forState:UIControlStateDisabled];
    [[UIBarButtonItem appearance] setTintColor:[Colors getButtonColor]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIButton appearanceWhenContainedIn:[UITableViewCell class], nil] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // Set the background color in the peoplepicker.
    [[UISearchBar appearance] setBarTintColor:[Colors getbackgroundColor]];
    
    // Set the color of the cancelButton of the search bar
    UIBarButtonItem *addressBookSearchBarCancelButton = [UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil];
    UIColor *addressBookSearchBarCancelButtonColor = [Colors getButtonColor];
    NSMutableDictionary *colorDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            addressBookSearchBarCancelButtonColor,
                                            NSForegroundColorAttributeName,
                                            nil];
    [colorDictionary setObject:addressBookSearchBarCancelButtonColor forKey:NSForegroundColorAttributeName];
    [addressBookSearchBarCancelButton setTitleTextAttributes:colorDictionary forState:UIControlStateNormal];
    
    // Set the sectionIndex color in the people picker
    [[UITableView appearance] setSectionIndexColor:[Colors getButtonColor]];
    
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
}

#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType
{
    if ([userActivityType isEqualToString:@"com.GreenHair.We-all-pay.SharingExpenses"]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    return YES;
}

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
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // open add payment
        UIStoryboard *storyboard = self.window.rootViewController.storyboard;
        UINavigationController *navPaymentViewController = [storyboard instantiateViewControllerWithIdentifier:@"navPaymentViewController"];
        PaymentViewController *paymentViewController = (PaymentViewController *)[navPaymentViewController viewControllers][0];
        paymentViewController.pathComponentsToOpen = pathDuringOpening;
        paymentViewController.tonightsBill = tonightsBill;
        [navController presentViewController:navPaymentViewController animated:YES completion:nil];
        // open tonightsBill
        UIViewController *mcRootViewController = navController.viewControllers[0];
        [mcRootViewController performSegueWithIdentifier:@"openEvent" sender:pathDuringOpening];
    } else {
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
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return NO;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    dispatch_once(&_executeOnlyOnce, ^{
        [self executeOnlyOnceDuringStartup];
        [[MCWeAllPayStoreController defaultStore] openStore:nil];
        
    });
    dispatch_queue_t someBackgroundQueue = dispatch_queue_create("originChech", NULL);
    dispatch_async(someBackgroundQueue, ^{
        [self checkToSeeIfThisPurchaseOriginatesFromiAd];
    });    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    dispatch_once(&_executeOnlyOnce, ^{
        [self executeOnlyOnceDuringStartup];
        [[MCWeAllPayStoreController defaultStore] openStore:nil];
    });
    [[MCStoreInterface defaultStoreInterface] validateProductIdentifiers];
    [self activateAnalytics];
    
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
    [self removeOldCurrencyStore];
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
