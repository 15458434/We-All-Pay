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

+ (MCWeAllPayStoreController *)defaultStore {
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
    if (_container == nil) {
        _container = [[NSPersistentContainer alloc] initWithName:MCWeAllPayStoreModelName];
        NSURL *weAllPayStoreURL = [NSURL URLWithString:@"/dev/null"];
        NSPersistentStoreDescription *storeDescription = [NSPersistentStoreDescription persistentStoreDescriptionWithURL:weAllPayStoreURL];
        storeDescription.type = NSInMemoryStoreType;
        [storeDescription setOption:@YES forKey:NSPersistentStoreRemoteChangeNotificationPostOptionKey];
        _container.persistentStoreDescriptions = @[storeDescription];
        [_container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
            if (error != nil) {
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.error = error;
                });
                completionHandler(self, NO);
                abort();
            } else {
                completionHandler(self, YES);
            }
        }];
        _container.viewContext.automaticallyMergesChangesFromParent = YES;
        _container.viewContext.undoManager = [[NSUndoManager alloc] init];
    }
}
#else
- (void)openStore {
    if (_container == nil) {
        _container = [[NSPersistentContainer alloc] initWithName:MCWeAllPayStoreModelName];
        NSURL *weAllPayStoreURL = [self weAllPayStoreURL];
        NSPersistentStoreDescription *storeDescription = [NSPersistentStoreDescription persistentStoreDescriptionWithURL:weAllPayStoreURL];
        [storeDescription setOption:@YES forKey:NSPersistentStoreRemoteChangeNotificationPostOptionKey];
        [storeDescription setOption:@YES forKey:NSInferMappingModelAutomaticallyOption];
        [storeDescription setOption:@YES forKey:NSMigratePersistentStoresAutomaticallyOption];
        _container.persistentStoreDescriptions = @[storeDescription];
        [_container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
            if (error) {
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.error = error;
                });
                abort();
            }
        }];
        self.viewContext.retainsRegisteredObjects = YES;
        self.viewContext.undoManager = [[NSUndoManager alloc] init];
        [self.viewContext.undoManager disableUndoRegistration];
        self.viewContext.automaticallyMergesChangesFromParent = YES;
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
#ifdef DEBUG
    NSLog(@"WeAllPayStorageFile: %@", result);
#endif
    return result;
}

- (void)performBackgroundTask:(void (^)(NSManagedObjectContext *))block {
    [_container performBackgroundTask:block];
}

- (void)saveViewContext {
#ifdef DEBUG
    NSLog(@"Saving viewContext: %@", self.viewContext);
#endif
    if (self.viewContext.hasChanges) {
        NSError *error;
        BOOL success = [self.viewContext save:&error];
        if (success) {
            NSLog(@"viewContext: Succesfully saved.");
        } else {
            NSLog(@"viewContext save not possible: %@", error);
        }
    }
}

#pragma mark - Undomanager stuff.

- (void)beginUndoGroup {
//    NSParameterAssert(_viewContext.undoManager);
    [self.viewContext.undoManager enableUndoRegistration];
    [self.viewContext.undoManager beginUndoGrouping];
}

- (void)beginUndoGroupWithoutRegistration {
//    NSParameterAssert(_viewContext.undoManager);
    [self.viewContext.undoManager beginUndoGrouping];
}

- (void)endUndoGroup {
//    NSParameterAssert(_viewContext.undoManager);
    [self.viewContext.undoManager endUndoGrouping];
    [self.viewContext.undoManager disableUndoRegistration];
}

- (void)endUndoGroupWithoutRegistration {
//    NSParameterAssert(_viewContext.undoManager);
    [self.viewContext.undoManager endUndoGrouping];
}

- (void)endUndoGroupAndProcess {
//    NSParameterAssert(_viewContext.undoManager);
    [self.viewContext.undoManager endUndoGrouping];
    [self.viewContext.undoManager disableUndoRegistration];
    [self.viewContext processPendingChanges];
}

- (void)endUndoGroupAndProcessWithoutRegistration {
//    NSParameterAssert(_viewContext.undoManager);
    [self.viewContext.undoManager endUndoGrouping];
    [self.viewContext processPendingChanges];
}

- (void)endUndoGroupAndUndo {
//    NSParameterAssert(_viewContext.undoManager);
    [self.viewContext.undoManager endUndoGrouping];
    [self.viewContext.undoManager undoNestedGroup];
    [self.viewContext.undoManager disableUndoRegistration];
}

- (void)endUndoGroupAndUndoWithoutRegistration {
//    NSParameterAssert(_viewContext.undoManager);
    [self.viewContext.undoManager endUndoGrouping];
    [self.viewContext.undoManager undoNestedGroup];
}

- (void)resetError {
    self.error = nil;
}

#pragma mark - Core Data Messages

- (void)startRespondingToStoreChangeNotifications
{
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self selector:@selector(storeWillSave:) name:NSManagedObjectContextWillSaveNotification object:self.viewContext];
    [dc addObserver:self selector:@selector(storeDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.viewContext];
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
    if (notification.object != self.viewContext) {
        [self.viewContext performBlockAndWait:^{
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
