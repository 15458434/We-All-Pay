//
//  MCAppDelegate.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import FirebaseCore;
@import FirebaseAnalytics;

#import "MCAppDelegate.h"
#import "MCAllTripsTableViewController.h"
#import "MCPaymentViewController.h"

#import "MCSharedBill+addons.h"
#import "MCPerson+CoreDataProperties.h"
#import "MCPayment+CoreDataProperties.h"

#import "UIColor+ColorSpawn.h"

#import "We_all_pay-Swift.h"

@interface MCAppDelegate ()

@property (nonatomic, strong) MCLaunchCounter *launchCounter;
@property (nonatomic, strong) MCCoreDataSaveHandlerWhenEnteringBackground *saveHandlerOnDidEnterBackground;
@property (nonatomic, strong) MCEventsModel *eventsModel;

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
    UINavigationBar.appearance.tintColor = [UIColor colorNamed:@"button - enabled"];
    UINavigationBar.appearance.backgroundColor = [UIColor colorNamed:@"navigationBar"];
    UINavigationBar.appearance.barTintColor = [UIColor colorWithColorType:MCColorTypeNavigationBar];
    UINavigationBar.appearance.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.whiteColor};
    
    UIBarButtonItem.appearance.tintColor = [UIColor colorNamed:@"button - enabled"];
    UINavigationBar.appearance.barStyle = UIBarStyleDefault;
    
    // Set the background color in the peoplepicker.
    UISearchBar.appearance.barTintColor = [UIColor colorNamed:@"background"];
    
    // Set the sectionIndex color in the people picker
    UITableView.appearance.sectionIndexColor = [UIColor colorNamed:@"button - enabled"];
    
    // Uncomment the following line to remove the In-App Purchase.
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.Greenhair.We_all_pay.pro"];
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifdef DEBUG
    NSLog(@"Application folder: %@", NSHomeDirectory());
    NSLog(@"UserDefaults on launch");
    NSLog(@"%@", NSUserDefaults.standardUserDefaults.dictionaryRepresentation);
    NSLog(@"**********************");
#endif
    
    [self executeOnlyOnceDuringStartup];
    WeAllPayStoreController *store = WeAllPayStoreController.defaultStore;
#ifdef SCREENSHOTS
    [store openStore:^(WeAllPayStoreController *store, BOOL success) {
        ScreenshotPopulationEngine *populator = [[ScreenshotPopulationEngine alloc] initWithManagedObjectContext:store.viewContext];
        [populator populate];
    }];
#else
    [store openStore];
    _eventsModel = [[MCEventsModel alloc] initWithManagedObjectContext:store.viewContext andFetchedResultsControllerdDelegate:nil];
#endif
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[MCStoreInterface defaultStoreInterface] validateProductIdentifiers];
    [self activateFirebase];
    
    [MCAdEngine registerDebugDevices];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    __block UIBackgroundTaskIdentifier taskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:taskIdentifier];
        taskIdentifier = UIBackgroundTaskInvalid;
    }];
    
    NSManagedObjectContext *context = WeAllPayStoreController.defaultStore.viewContext;
    self.saveHandlerOnDidEnterBackground = [[MCCoreDataSaveHandlerWhenEnteringBackground alloc] initWithContext:context];
    [self.saveHandlerOnDidEnterBackground saveAndEndBackgroundTaskWithIdentifier:taskIdentifier];
}

- (BOOL)application:(UIApplication *)application shouldSaveSecureApplicationState:(NSCoder *)coder {
    return NO;
}

- (BOOL)application:(UIApplication *)application shouldRestoreSecureApplicationState:(NSCoder *)coder {
    return NO;
}

- (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType {
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
    NSString *eventId = pathComponents[1];
    NSString *nextPayerId = pathComponents[2];
    
    // Verify existense of event
    NSError *fetchError;
    MCSharedBill *event = [_eventsModel eventWith:eventId error:&fetchError];
    if (fetchError) {
        NSLog(@"Unable to open this event.");
        return NO;
    }
    // Verify existense of person on event
    CurrencyController *currencyController = [[CurrencyController alloc] init];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:_eventsModel.managedObjectContext andWithCurrencyController:currencyController];
    MCEventModel *eventModel = [[MCEventModel alloc] initWithEvent:event andConcurrencyModel:currencyModel];
    NSError *fetchPersonError;
    MCPerson *nextPayer = [eventModel fetchPersonWithUniqueID:nextPayerId withError:&fetchPersonError];
    if (fetchPersonError || !nextPayer) {
        NSLog(@"Unable to find specified person");
        return NO;
    }
    // Navigate to the add payment screen.
    NSArray<NSManagedObject *> *pathDuringOpening = @[event, nextPayer];
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    [navController popToRootViewControllerAnimated:NO];
    
    // open add payment
    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
    UINavigationController *navPaymentViewController = [storyboard instantiateViewControllerWithIdentifier:@"navPaymentViewController"];
    MCPaymentViewController *paymentViewController = (MCPaymentViewController *)[navPaymentViewController viewControllers][0];
    [paymentViewController prepareForUseWithPathComponentsToOpen:pathDuringOpening];
    [navController presentViewController:navPaymentViewController animated:YES completion:nil];
    // open tonightsBill
    MCAllTripsTableViewController *allTripsViewController = (MCAllTripsTableViewController *)navController.viewControllers[0];
    [allTripsViewController prepareForUseWithPathComponentsToOpen:pathDuringOpening];
    
    return YES;
}

#pragma mark - UIResponder

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Start views" object:nil];
}

@end
