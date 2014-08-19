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

@interface XRCurrencyStoreController : NSObject

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext *backgroundContext;
@property (nonatomic, strong) NSManagedObjectContext *mainQueueContext;

+ (BOOL)doesMyCurrencyDatabaseFileExist;
+ (void)populateCurrencyDataBaseIfEmptyForContext:(NSManagedObjectContext *)context;
+ (id)sharedStore;

- (void)prepareStoreWithCompletionHandler:(void (^)())completionHandler;
- (XRCurrency *)fetchCurrencyWithCode:(NSString *)code inContext:(NSManagedObjectContext *)context;
- (void)fetchCurrencyWithCode:(NSString *)code withCompletionHandler:(void (^)(XRCurrency *fetchedCurrency))completionHandler;

#if TARGET_OS_IPHONE
- (NSFetchedResultsController *)getFetchedResultsControllerForDelegate:(id)delegate;
#elif TARGET_OS_MAC
#endif

@end
