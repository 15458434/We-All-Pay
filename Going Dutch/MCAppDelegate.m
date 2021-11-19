//
//  MCAppDelegate.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import Firebase;
@import FirebaseAnalytics;

#import "MCAppDelegate.h"
#import "MCAllTripsTableViewController.h"
#import "MCPaymentViewController.h"

#import "MCRoundedButton.h"

#import "MCWeAllPayStoreController.h"

#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"
#import "MCPayment+addons.h"

#import "UIColor+ColorSpawn.h"

#import "We_all_pay-Swift.h"

@interface MCAppDelegate ()

@property (nonatomic, strong) MCLaunchCounter *launchCounter;
@property (nonatomic, strong) MCCoreDataSaveHandlerWhenEnteringBackground *saveHandlerOnDidEnterBackground;

@end

@implementation MCAppDelegate

#pragma mark - New in this class

- (void)activateFirebase {
    [FIRApp configure];
    [MCRemoteConfigEngine prepareRemoteConfig];
    
    _launchCounter = [[MCLaunchCounter alloc] init];
    [_launchCounter increment];
}

- (void)executeOnlyOnceDuringStartup {
    // Override point for customization after application launch.
    NSOperationQueue *someQueue = [[NSOperationQueue alloc] init];
    someQueue.name = @"Logging start";
    [someQueue addOperationWithBlock:^{
        NSLog(@"%@ running iOS %@", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion]);
        NSLog(@"I dedicated this app to my wonderful daughter Annemoon, because I love her so much.");
#ifdef DEBUG
        NSLocale *locale = [NSLocale currentLocale];
        NSString *languageCode = [locale objectForKey:NSLocaleLanguageCode];
        NSLog(@"The current language code is: %@", languageCode);
#endif
    }];
    
    // UINavigationBar.appearance
    if (@available(iOS 15.0, *)) {
        UINavigationBar.appearance.tintColor = [UIColor colorNamed:@"button - enabled"];
        UINavigationBar.appearance.backgroundColor = [UIColor colorNamed:@"navigationBar"];
        UINavigationBar.appearance.barTintColor = [UIColor colorWithColorType:MCColorTypeNavigationBar];
    } else if (@available(iOS 11.0, *)) {
        UINavigationBar.appearance.barTintColor = [UIColor colorNamed:@"navigationBar"];
        UINavigationBar.appearance.tintColor = [UIColor colorNamed:@"button - enabled"];
    } else {
        // Fallback on earlier versions
        UINavigationBar.appearance.barTintColor = [UIColor colorWithColorType:MCColorTypeNavigationBar];
        UINavigationBar.appearance.tintColor = [UIColor colorWithColorType:MCColorTypeButtonEnabled];
        
    };
    UINavigationBar.appearance.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.whiteColor};
    
    if (@available(iOS 11.0, *)) {
        UIBarButtonItem.appearance.tintColor = [UIColor colorNamed:@"button - enabled"];
    } else {
        // Fallback on earlier versions
        UIBarButtonItem.appearance.tintColor = [UIColor colorWithColorType:MCColorTypeButtonEnabled];
    }
    UINavigationBar.appearance.barStyle = UIBarStyleBlackTranslucent;
    
    // Set the color of the cancelButton of the search bar
    UIBarButtonItem *addressBookSearchBarCancelButton = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]];
    UIColor *addressBookSearchBarCancelButtonColor;
    if (@available(iOS 11.0, *)) {
        addressBookSearchBarCancelButtonColor = [UIColor colorNamed:@"button - enabled"];
    } else {
        // Fallback on earlier versions
        addressBookSearchBarCancelButtonColor = [UIColor colorWithColorType:MCColorTypeButtonEnabled];
    }
    NSMutableDictionary *colorDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            addressBookSearchBarCancelButtonColor,
                                            NSForegroundColorAttributeName,
                                            nil];
    [colorDictionary setObject:addressBookSearchBarCancelButtonColor forKey:NSForegroundColorAttributeName];
    [addressBookSearchBarCancelButton setTitleTextAttributes:colorDictionary forState:UIControlStateNormal];
    
    if (@available(iOS 11.0, *)) {
        [UIButton.appearance setTitleColor:[UIColor colorNamed:@"button - enabled"] forState:UIControlStateNormal];
    } else {
        // Fallback on earlier versions
        [UIButton.appearance setTitleColor:[UIColor colorWithColorType:MCColorTypeButtonEnabled] forState:UIControlStateNormal];
    }
    if (@available(iOS 13.0, *)) {
        [MCRoundedButton.appearance setTitleColor:UIColor.systemBackgroundColor forState:UIControlStateNormal];
        [MCRoundedButton.appearance setTitleColor:UIColor.systemBackgroundColor forState:UIControlStateHighlighted];
    } else {
        [MCRoundedButton.appearance setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [MCRoundedButton.appearance setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    }

    if (@available(iOS 11.0, *)) {
        [UIButton.appearance setTitleColor:[UIColor colorNamed:@"button - disabled"] forState:UIControlStateDisabled];
    } else {
        // Fallback on earlier versions
        [UIButton.appearance setTitleColor:[UIColor colorWithColorType:MCColorTypeButtonDisabled] forState:UIControlStateDisabled];
    }
    [[UIButton appearanceWhenContainedInInstancesOfClasses:@[[UITableViewCell class]]] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    // Set the background color in the peoplepicker.
    if (@available(iOS 11.0, *)) {
        UISearchBar.appearance.barTintColor = [UIColor colorNamed:@"background"];
    } else {
        // Fallback on earlier versions
        UISearchBar.appearance.barTintColor = [UIColor colorWithColorType:MCColorTypeBackground];
    }
    
    if (@available(iOS 11.0, *)) {
        [[UIButton appearanceWhenContainedInInstancesOfClasses:@[NSClassFromString(@"UISwipeActionPullView")]] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    // Set the sectionIndex color in the people picker
    if (@available(iOS 11.0, *)) {
        UITableView.appearance.sectionIndexColor = [UIColor colorNamed:@"button - enabled"];
    } else {
        // Fallback on earlier versions
        UITableView.appearance.sectionIndexColor = [UIColor colorWithColorType:MCColorTypeButtonEnabled];
    }
    
    // Uncomment the following line to remove the In-App Purchase.
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.Greenhair.We_all_pay.pro"];
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

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
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
    [paymentViewController prepareForUseWithPathComponentsToOpen:pathDuringOpening];
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

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifdef DEBUG
    NSLog(@"UserDefaults on launch");
    NSLog(@"%@", NSUserDefaults.standardUserDefaults.dictionaryRepresentation);
    NSLog(@"**********************");
#endif
    
    [self executeOnlyOnceDuringStartup];
#ifdef SCREENSHOTS
    [[MCWeAllPayStoreController defaultStore] openStore:^(MCWeAllPayStoreController *store, BOOL success) {
        ScreenshotPopulationEngine *populator = [[ScreenshotPopulationEngine alloc] initWithManagedObjectContext:store.mainThreadContext];
        [populator populate];
    }];
#else
    [[MCWeAllPayStoreController defaultStore] openStore:nil];
#endif
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[MCStoreInterface defaultStoreInterface] validateProductIdentifiers];
    [self activateFirebase];
    
    [MCAdEngine registerDebugDevices];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    __block UIBackgroundTaskIdentifier taskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:taskIdentifier];
        taskIdentifier = UIBackgroundTaskInvalid;
    }];
    
    NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
    self.saveHandlerOnDidEnterBackground = [[MCCoreDataSaveHandlerWhenEnteringBackground alloc] initWithContext:context];
    [self.saveHandlerOnDidEnterBackground saveAndEndBackgroundTaskWithIdentifier:taskIdentifier];
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
