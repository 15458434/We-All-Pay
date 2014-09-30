//
//  MCCurrencyStoreController.m
//  We all pay
//
//  Created by Mark Cornelisse on 18/08/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "XRCurrencyStoreController.h"
#import "XRCurrency.h"
#import "XRCurrencyXRateFetcher.h"

#import "MCxRatesController.h"

NSString * const XRCurrencyModel = @"XRCurrency";
NSString * const XRCurrencyBaseDirectory = @"XRCurrency";
NSString * const XRCurrencyStoreFileName = @"XRCurrencyStore";
NSString * const XRCurrencyStoreFileExtension = @"sqlite";

NSString * const XRCurrencyDatabaseVersionKey = @"XRCurrencyDatabaseVersionKey";

@interface XRCurrencyStoreController ()

@end

@implementation XRCurrencyStoreController

#pragma mark - New in this class

+ (BOOL)doesMyCurrencyDatabaseFileExist
{
    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *directoryURL = [applicationDocumentsDirectory URLByAppendingPathComponent:XRCurrencyBaseDirectory isDirectory:YES];
    NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    NSString *fullFileName = [NSString stringWithFormat:@"%@-%@.%@", XRCurrencyStoreFileName, languageCode ,XRCurrencyStoreFileExtension];
    NSURL *storeURL = [directoryURL URLByAppendingPathComponent:fullFileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:storeURL.path]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)doesMyDatabaseHaveTheRightVersion
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLocale *myLocale = [NSLocale currentLocale];
    NSString *languageCode = [myLocale objectForKey:NSLocaleLanguageCode];
    NSMutableString *localizedXRCurrencyDatabaseVersionKey = [XRCurrencyDatabaseVersionKey mutableCopy];
    [localizedXRCurrencyDatabaseVersionKey appendString:languageCode];
    NSString *xrCurrencyDatabaseVersion = [defaults objectForKey:localizedXRCurrencyDatabaseVersionKey];
    if ([xrCurrencyDatabaseVersion integerValue] < 1 || !xrCurrencyDatabaseVersion) {
#if DEBUG
        NSLog(@"Currency Database version number not up to date.");
#endif
        return NO;
    } else {
#if DEBUG
        NSLog(@"Currency Database version number up to date.");
#endif
        return YES;
    }
}

+ (void)updateMyDatabase
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLocale *myLocale = [NSLocale currentLocale];
    NSString *languageCode = [myLocale objectForKey:NSLocaleLanguageCode];
    NSMutableString *localizedXRCurrenceDatabaseVersionKey = [XRCurrencyDatabaseVersionKey mutableCopy];
    [localizedXRCurrenceDatabaseVersionKey appendString:languageCode];
    NSString *databaseVersion = [defaults objectForKey:localizedXRCurrenceDatabaseVersionKey];
    switch ([databaseVersion integerValue]) {
        case 1:
            NSLog(@"XRCurrency is already up to date.");
            break;
        default: {
            // Get current language
            // if current language is dutch update
            if ([languageCode isEqualToString:@"nl"]) {
#if DEBUG
                NSLog(@"Language is dutch");
#endif
                NSDictionary *currencyDictionary = [MCxRatesController getCurrencyDictionary];
                NSDictionary *turkishCurrency = [currencyDictionary objectForKey:@"TRY"];
#if DEBUG
                NSLog(@"Gevonden %@", [turkishCurrency objectForKey:@"name"]);
#endif
                NSManagedObjectContext *backgroundContext = [[XRCurrencyStoreController sharedStore] backgroundContext];
                [backgroundContext performBlock:^{
                    XRCurrency *turkishLira = [[XRCurrencyStoreController sharedStore] fetchCurrencyWithCode:@"TRY" inContext:backgroundContext];
                    [turkishLira setName:[turkishCurrency objectForKey:@"name"]];
                    NSError *saveError;
                    if (![backgroundContext save:&saveError]) {
                        NSLog(@"Something went wrong saving: %@", saveError);
                    } else {
                        [defaults setObject:@1 forKey:localizedXRCurrenceDatabaseVersionKey];
                        [defaults synchronize];
                    }
                }];
            }
            // update version number
        }
            break;
    }
}

+ (void)populateCurrencyDataBaseIfEmptyForContext:(NSManagedObjectContext *)context
{
    // Unit tested.
    // Check to see if currency database is filled.
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XRCurrency"];
    NSSortDescriptor *sortDecriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateModified" ascending:YES];
    request.sortDescriptors = @[sortDecriptor];
    NSError *countError;
    NSUInteger amountOfCurrencies = [context countForFetchRequest:request error:&countError];
    if (countError) {
        NSLog(@"Error counting currencies: %@", countError);
    }
    // If empty fill it.
    if (amountOfCurrencies == 0) {
        NSDictionary *availableCurrencies = [MCxRatesController getCurrencyDictionary];
        NSArray *availableCurrencyCodes = [availableCurrencies allKeys];
        for (NSString *currencyCode in availableCurrencyCodes) {
            // For each currencyCode add it.
            XRCurrency *newCurrency = [NSEntityDescription insertNewObjectForEntityForName:@"XRCurrency" inManagedObjectContext:context];
            NSString *uuidString = [[NSUUID UUID] UUIDString];
            NSDate *now = [NSDate date];
            NSString *currencyName = [[availableCurrencies objectForKey:currencyCode] objectForKey:@"name"];
            NSString *currencySymbol = [MCxRatesController getSymbolForCurrencyISOCode:currencyCode];
            [newCurrency setUniqueID:uuidString];
            [newCurrency setDateCreated:now];
            [newCurrency setDateModified:now];
            [newCurrency setIsStillValid:@YES];
            [newCurrency setName:currencyName];
            [newCurrency setCode:currencyCode];
            [newCurrency setSymbol:currencySymbol];
            NSLog(@"Generated MCCurrency: %@", newCurrency);
        }
        NSError *saveError;
        if (![context save:&saveError]) {
            NSLog(@"Something went wrong saving XRCurrencies: %@", saveError);
            abort();
        }
    }
}

- (void)prepareStoreWithCompletionHandler:(void (^)())completionHandler
{
    NSOperationQueue *thisQueue = [NSOperationQueue currentQueue];
    NSManagedObjectContext *context = [self backgroundContext];
    [context performBlock:^{
        // Check to see if currency database is filled.
        [XRCurrencyStoreController populateCurrencyDataBaseIfEmptyForContext:context];
        [thisQueue addOperationWithBlock:^{
            completionHandler();
        }];
    }];
}

- (XRCurrency *)fetchCurrencyWithCode:(NSString *)code inContext:(NSManagedObjectContext *)context
{
    // should be executed in the queue of the context
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XRCurrency"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES];
    request.sortDescriptors = @[sortDescriptor];
    request.predicate = [NSPredicate predicateWithFormat:@"code like %@", code];
    NSError *currencyFetchError;
    NSArray *fetchCurrencies = [context executeFetchRequest:request error:&currencyFetchError];
    if (currencyFetchError) {
        NSLog(@"Error fetching XRCurrency %@", currencyFetchError);
    }
    return [fetchCurrencies firstObject];
}

- (void)fetchCurrencyWithCode:(NSString *)code withCompletionHandler:(void (^)(XRCurrency *))completionHandler
{
    NSOperationQueue *thisQueue = [NSOperationQueue currentQueue];
    _backgroundContext = [self backgroundContext];
    [_backgroundContext performBlock:^{
        XRCurrency *fetchedCurrency = [self fetchCurrencyWithCode:code inContext:_backgroundContext];
        [thisQueue addOperationWithBlock:^{
            completionHandler(fetchedCurrency);
        }];
    }];
}

#if TARGET_OS_IPHONE
- (NSFetchedResultsController *)getFetchedResultsControllerForDelegate:(id)delegate
{
    if (delegate) {
        // Delegate should conform to NSFetchedResultsControllerDelegate.
        NSParameterAssert([delegate conformsToProtocol:@protocol(NSFetchedResultsControllerDelegate)]);
    }
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XRCurrency"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = @[sortDescriptor];
    
    NSFetchedResultsController *dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[self mainQueueContext] sectionNameKeyPath:nil cacheName:nil];
    dataController.delegate = delegate;
    
    return dataController;
}
#elif TARGET_OS_MAC
#endif

- (XRCurrencyXRateFetcher *)xRateFetcher
{
    if (!_xRateFetcher) {
        _xRateFetcher = [[XRCurrencyXRateFetcher alloc] init];
    }
    return _xRateFetcher;
}

#pragma mark - SingleTon

+ (id)sharedStore {
    static XRCurrencyStoreController *centralStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        centralStore = [[self alloc] init];
    });
    return centralStore;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - Core Data Stack

- (NSManagedObjectContext *)mainQueueContext
{
    if (_mainQueueContext != nil) {
        return _mainQueueContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainQueueContext setPersistentStoreCoordinator:coordinator];
    }
    return _mainQueueContext;
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)backgroundContext
{
    if (_backgroundContext != nil) {
        return _backgroundContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backgroundContext setPersistentStoreCoordinator:coordinator];
    }
    return _backgroundContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:XRCurrencyModel withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *directoryURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:XRCurrencyBaseDirectory isDirectory:YES];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:directoryURL.path]) {
        NSError *directoryCreationError;
        if (![fileManager createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&directoryCreationError ]){
            NSLog(@"Unable to create base directory for XRCurrencyStore: %@", directoryCreationError);
        }
    }
    NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    NSString *fullFileName = [NSString stringWithFormat:@"%@-%@.%@", XRCurrencyStoreFileName, languageCode ,XRCurrencyStoreFileExtension];
    NSURL *storeURL = [directoryURL URLByAppendingPathComponent:fullFileName];
    
    NSError *error = nil;
    NSDictionary *storeOptions = @{NSInferMappingModelAutomaticallyOption: @YES,
                                   NSMigratePersistentStoresAutomaticallyOption: @YES};
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:storeOptions error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
