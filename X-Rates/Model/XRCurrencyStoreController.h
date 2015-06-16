//
//  MCCurrencyStoreController.h
//  We all pay
//
//  Created by Mark Cornelisse on 18/08/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Foundation;
@import CoreData;

@class XRCurrency;
@class XRCurrencyXRateFetcher;

__deprecated
@interface XRCurrencyStoreController : NSObject

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator __deprecated;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel __deprecated;
@property (nonatomic, strong) NSManagedObjectContext *backgroundContext __deprecated;
@property (nonatomic, strong) NSManagedObjectContext *mainQueueContext __deprecated;
@property (nonatomic, strong) NSManagedObjectContext *secondMainQueueContext __deprecated;
@property (nonatomic, strong) XRCurrencyXRateFetcher *xRateFetcher __deprecated;

+ (BOOL)doesMyCurrencyDatabaseFileExist __deprecated;
+ (BOOL)doesMyDatabaseHaveTheRightVersion __deprecated;
+ (void)updateMyDatabase __deprecated;

+ (void)populateCurrencyDataBaseIfEmptyForContext:(NSManagedObjectContext *)context __deprecated;
+ (id)sharedStore __deprecated;

- (void)prepareStoreWithCompletionHandler:(void (^)())completionHandler __deprecated;
- (XRCurrency *)fetchCurrencyWithCode:(NSString *)code inContext:(NSManagedObjectContext *)context __deprecated;
- (void)fetchCurrencyWithCode:(NSString *)code withCompletionHandler:(void (^)(XRCurrency *fetchedCurrency))completionHandler __deprecated;
- (NSArray *)fetchAllCurrenciesForContext:(NSManagedObjectContext *)context __deprecated;

#if TARGET_OS_IPHONE
- (NSFetchedResultsController *)getFetchedResultsControllerForDelegate:(id)delegate __deprecated;
#elif TARGET_OS_MAC
#endif

@end
