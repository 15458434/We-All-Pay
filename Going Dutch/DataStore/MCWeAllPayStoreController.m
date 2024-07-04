//
//  MCWeAllPayStoreController.m
//  We all pay
//
//  Created by Mark Cornelisse on 08-07-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCWeAllPayStoreController.h"

#import "MCPerson+addons.h"
#import "MCPayment.h"
#import "MCSharedBill.h"
#import "MCCurrency+addons.h"
#import "MCExchangeRate+addons.h"

#import "MCThisPaymentProtocol.h"

#import "We_all_pay-Swift.h"


// This is the name of the WeAllPayStoreFile. It's inherited from the location where UIManagedDocumentStores it's database file.
NSString * const MCWeAllPayStoreFileName = @"persistentStore";
NSString * const MCWeAllPayStoreDirectoryName = @"WeAllPayStore/StoreContent";
// File of the WeAllPayStore Database model file.
NSString * const MCWeAllPayStoreModelName = @"WeAllPayStore";

@interface MCWeAllPayStoreController ()

@property (nonatomic, strong, readwrite) NSPersistentContainer *container;
@property (nonatomic, strong, nullable) NSError *error;

@end

@implementation MCWeAllPayStoreController

@synthesize fetcher = _fetcher;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize viewContext = _viewContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Internal methods



#pragma mark - New in this class

- (ExchangeRateFetcher *)fetcher
{
    if (_fetcher == nil) {
        return [[ExchangeRateFetcher alloc] init];
    } else {
        return _fetcher;
    }
}

+ (instancetype)defaultStore
{
    static MCWeAllPayStoreController *sharedStore = nil;
    @synchronized (self) {
        if (sharedStore == nil) {
            sharedStore = [[MCWeAllPayStoreController alloc] init];
        }
    }
    return sharedStore;
}

#ifdef SCREENSHOTS
- (void)openStore:(void (^_Nullable)(MCWeAllPayStoreController *store, BOOL success))completionHandler {
    [self mainThreadContext];
    [self backgroundThreadContext];
    [self startRespondingToStoreChangeNotifications];
    if (_mainThreadContext && _backgroundThreadContext) {
        _mainThreadContext.undoManager = [[NSUndoManager alloc] init];
        [[_mainThreadContext undoManager] disableUndoRegistration];
        if (completionHandler) {
            completionHandler(self, YES);
        }
    } else {
        NSLog(@"Unable to open We All Pay Store.");
        if (completionHandler) {
            completionHandler(self, NO);
        }
    }
}
#else
- (void)openStore {
    if (_container == nil) {
        _container = [[NSPersistentContainer alloc] initWithName:MCWeAllPayStoreModelName];
        
        NSURL *weAllPayStoreURL = [self weAllPayStoreURL];
        
        NSPersistentStoreDescription *storeDescription = [NSPersistentStoreDescription persistentStoreDescriptionWithURL:weAllPayStoreURL];
//        storeDescription.type = NSInMemoryStoreType;
        [storeDescription setOption:@YES forKey:NSPersistentHistoryTrackingKey];
        [storeDescription setOption:@YES forKey:NSPersistentStoreRemoteChangeNotificationPostOptionKey];
        
        _container.persistentStoreDescriptions = @[storeDescription];
        
        [_container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
            if (error != nil) {
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.error = error;
                });
                abort();
            } else {
                
            }
        }];
        _container.viewContext.automaticallyMergesChangesFromParent = YES;
    }
}
#endif

- (NSURL *)weAllPayStoreURL {
    NSURL *weAllPayStorageFolder = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:MCWeAllPayStoreDirectoryName];
    // Create the subdirectory if it doesn't exist
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtURL:weAllPayStorageFolder withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"Failed to create directory: %@", error);
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.error = error;
        });
    }
    NSURL *result = [weAllPayStorageFolder URLByAppendingPathComponent:MCWeAllPayStoreFileName];
    NSLog(@"WeAllPayStorageFile: %@", result);
    return result;
}

- (void)performBackgroundTask:(void (^)(NSManagedObjectContext *))block {
    [_container performBackgroundTask:block];
}

- (void)saveViewContext {
    if (self.viewContext.hasChanges) {
        NSError *error;
        BOOL succes = [_viewContext save:&error];
        if (succes) {
            NSLog(@"Main Thread Context: Succesfully saved.");
        } else {
            NSLog(@"MainQueue save not possible: %@", error);
        }
    }
}

#pragma mark - Undomanager stuff.

- (void)beginUndoGroup {
    [_viewContext.undoManager enableUndoRegistration];
    [_viewContext.undoManager beginUndoGrouping];
}

- (void)beginUndoGroupWithoutRegistration {
    [_viewContext.undoManager beginUndoGrouping];
}

- (void)endUndoGroup {
    [_viewContext.undoManager endUndoGrouping];
    [_viewContext.undoManager disableUndoRegistration];
}

- (void)endUndoGroupWithoutRegistration {
    [_viewContext.undoManager endUndoGrouping];
}

- (void)endUndoGroupAndProcess {
    [_viewContext.undoManager endUndoGrouping];
    [_viewContext.undoManager disableUndoRegistration];
    [_viewContext processPendingChanges];
}

- (void)endUndoGroupAndProcessWithoutRegistration {
    [_viewContext.undoManager endUndoGrouping];
    [_viewContext processPendingChanges];
}

- (void)endUndoGroupAndUndo {
    [_viewContext.undoManager endUndoGrouping];
    [_viewContext.undoManager undoNestedGroup];
    [_viewContext.undoManager disableUndoRegistration];
}

- (void)endUndoGroupAndUndoWithoutRegistration {
    [_viewContext.undoManager endUndoGrouping];
    [_viewContext.undoManager undoNestedGroup];
}

- (void)resetError {
    self.error = nil;
}

#pragma mark - Core Data Messages

- (void)startRespondingToStoreChangeNotifications
{
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self selector:@selector(storeWillSave:) name:NSManagedObjectContextWillSaveNotification object:_viewContext];
    [dc addObserver:self selector:@selector(storeDidSave:) name:NSManagedObjectContextDidSaveNotification object:_viewContext];
}

- (void)stopRespondingToStorechangeNotifications
{
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc removeObserver:self];
}

- (void)storeWillSave:(NSNotification *)notification
{
#ifdef DEBUG
    NSLog(@"MCWeAllPayStoreController: Store will save.");
#endif
}

- (void)storeDidSave:(NSNotification *)notification
{
#ifdef DEBUG
    NSLog(@"MCWeAllPayStoreController: Store did save.");
#endif
    if (notification.object != _viewContext) {
        [_viewContext performBlockAndWait:^{
#ifdef DEBUG
            NSLog(@"Merging changes into mainContext.");
#endif
            [self.viewContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

#pragma mark - Core Data Stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)viewContext {
    return _container.viewContext;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
