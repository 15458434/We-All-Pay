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

#import "MCTonightsBillTransfer.h"
#import "MCThisPaymentProtocol.h"

#import "We_all_pay-Swift.h"

typedef NS_ENUM(BOOL, MCiCloudUse) {
    iCloudIsNotUsed,
    iCloudIsUsed
};

// This is the name of the WeAllPayStoreFile. It's inherited from the location where UIManagedDocumentStores it's database file.
NSString * const MCWeAllPayStoreFileName = @"persistentStore";
NSString * const MCWeAllPayStoreDirectoryName = @"WeAllPayStore/StoreContent";
// File of the WeAllPayStore Database model file.
NSString * const MCWeAllPayStoreModelName = @"WeAllPayStore";

NSString * const MCiCloudWeAllPayStoreName = @"iCloud-WeAllPayStore";
MCiCloudUse const isiCloudUsed = iCloudIsNotUsed;

@interface MCWeAllPayStoreController ()

@end

@implementation MCWeAllPayStoreController

@synthesize weAllPayStoreDocument;

@synthesize managedObjectModel = _managedObjectModel;
@synthesize mainThreadContext = _mainThreadContext;
@synthesize backgroundThreadContext = _backgroundThreadContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Internal methods



#pragma mark - New in this class

- (void)storeIsReady:(NSNotification *)notification
{
    if ([weAllPayStoreDocument documentState] == UIDocumentStateNormal) {
        NSLog(@"Document is ready to use.");
    }
}

+ (MCWeAllPayStoreController *)defaultStore
{
    static MCWeAllPayStoreController *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
        NSOperationQueue *someQueue = [[NSOperationQueue alloc] init];
        someQueue.name = @"Fetcher Initialiser";
        [someQueue addOperationWithBlock:^{
            sharedStore.fetcher = [[ExchangeRateFetcher alloc] init];
        }];
    }
    return sharedStore;
}

- (void)openStore:(void (^)(BOOL success))completionHandler
{
    [self mainThreadContext];
    [self backgroundThreadContext];
    [self startRespondingToStoreChangeNotifications];
    if (_mainThreadContext && _backgroundThreadContext) {
        _mainThreadContext.undoManager = [[NSUndoManager alloc] init];
        [[_mainThreadContext undoManager] disableUndoRegistration];
        if (completionHandler) {
            completionHandler(YES);
        }
    } else {
        NSLog(@"Unable to open We All Pay Store.");
        if (completionHandler) {
            completionHandler(NO);
        }
    }
}

- (void)saveMainThreadContext
{
    NSError *error;
    BOOL succes = [_mainThreadContext save:&error];
    if (succes) {
        NSLog(@"Main Thread Context: Succesfully saved.");
    } else {
        NSLog(@"MainQueue save not possible: %@", error);
    }
}

- (void)savebackgroundContext
{
    NSError *error;
    BOOL succes = [_backgroundThreadContext save:&error];
    if (succes) {
        NSLog(@"Background Thread Context Succesfully saved.");
    } else {
        NSLog(@"Background save not possible: %@", error);
    }
}

- (void)closeDocument
{
    [weAllPayStoreDocument closeWithCompletionHandler:^(BOOL success){
        if (success) {
            NSLog(@"UIManagedDocument was succesfully closed.");
        } else {
            NSLog(@"Close not possible for document at %@", [weAllPayStoreDocument fileURL]);
        }
    }];
}

- (BOOL)isDocumentStateNormal
{
#if DEBUG
    NSLog(@"Warning: isDocumentStateNormal should not be executed.");
    abort();
#endif
    if ([weAllPayStoreDocument documentState] == UIDocumentStateNormal) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Undomanager stuff.

- (void)beginUndoGroup
{
    [[_mainThreadContext undoManager] enableUndoRegistration];
    [[_mainThreadContext undoManager] beginUndoGrouping];
}

- (void)beginUndoGroupWithoutRegistration
{
    [[_mainThreadContext undoManager] beginUndoGrouping];
}

- (void)endUndoGroup
{
    [[_mainThreadContext undoManager] endUndoGrouping];
    [[_mainThreadContext undoManager] disableUndoRegistration];
}

- (void)endUndoGroupWithoutRegistration
{
    [[_mainThreadContext undoManager] endUndoGrouping];
}

- (void)endUndoGroupAndProcess
{
    [[_mainThreadContext undoManager] endUndoGrouping];
    [[_mainThreadContext undoManager] disableUndoRegistration];
    [_mainThreadContext processPendingChanges];
}

- (void)endUndoGroupAndProcessWithoutRegistration
{
    [[_mainThreadContext undoManager] endUndoGrouping];
    [_mainThreadContext processPendingChanges];
}

- (void)endUndoGroupAndUndo
{
    [[_mainThreadContext undoManager] endUndoGrouping];
    [[_mainThreadContext undoManager] undoNestedGroup];
    [[_mainThreadContext undoManager] disableUndoRegistration];
}

- (void)endUndoGroupAndUndoWithoutRegistration
{
    [[_mainThreadContext undoManager] endUndoGrouping];
    [[_mainThreadContext undoManager] undoNestedGroup];
}

#pragma mark - TableView fill sources.

- (NSFetchedResultsController *)allTripsDataControllerForDelegate:(id)delegate
{
#if DEBUG
    NSLog(@"%@, allTripsDataControllerForDelegate", self);
#endif
    NSParameterAssert([delegate conformsToProtocol:@protocol(NSFetchedResultsControllerDelegate)]);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCSharedBill"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO]];
    request.relationshipKeyPathsForPrefetching = @[ @"payments", @"peoplePresent", @"mainCurrency", @"payments.exchangeRate", @"payments.peopleSharingPayment" ];
    NSFetchedResultsController *dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                         managedObjectContext:_mainThreadContext
                                                           sectionNameKeyPath:nil
                                                                    cacheName:nil];
    [dataController setDelegate:delegate];
    
    return dataController;
}

- (NSFetchedResultsController *)sharedBillPaymentsDataControllerForDelegate:(id)delegate
{
#if DEBUG
    NSLog(@"%@, sharedBillPaymentsDataControllerForDelegate", self);
#endif
    NSParameterAssert([delegate conformsToProtocol:@protocol(NSFetchedResultsControllerDelegate)]);
    NSParameterAssert([delegate conformsToProtocol:@protocol(MCTonightsBillTransfer)]);
    MCSharedBill *tonightsBill = [delegate tonightsBill];
    // What entities will be fetched.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPayment"];
    [request setRelationshipKeyPathsForPrefetching:@[ @"payingPerson", @"exchangeRate", @"currency" ]];
    // How to sort the data.
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO];
    NSArray *sortDescriptorArray = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptorArray];
    // Select only people from tonightsBill.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"onWhichBill = %@", tonightsBill];
    [request setPredicate:predicate];
    
    // Create the FetchedResultsController.
    NSFetchedResultsController *dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_mainThreadContext sectionNameKeyPath:nil cacheName:nil];
    [dataController setDelegate:delegate];
    return dataController;
}

- (NSFetchedResultsController *)sharedBillPeoplePresentDataControllerForDelegate:(id)delegate
{
#if DEBUG
    NSLog(@"%@ sharedBillPeoplePresentDataControllerForDelegate", self);
#endif
    NSParameterAssert([delegate conformsToProtocol:@protocol(NSFetchedResultsControllerDelegate)]);
    NSParameterAssert([delegate conformsToProtocol:@protocol(MCTonightsBillTransfer)]);
    MCSharedBill *tonightsBill = [delegate tonightsBill];
    // What entities will be fetched.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
    // How to sort the data.
    request.relationshipKeyPathsForPrefetching = @[ @"emailAddress", @"payments", @"sharedBill", @"sharedBill.mainCurrency", @"payments.currency" ];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO]];
    // Select only people from tonightsBill.
    request.predicate = [NSPredicate predicateWithFormat:@"ANY sharedBill = %@", tonightsBill];
    
    // Create the FetchedResultsController.
    NSFetchedResultsController *dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_mainThreadContext sectionNameKeyPath:nil cacheName:nil];
    [dataController setDelegate:delegate];
    return dataController;
}

- (NSFetchedResultsController *)paymentPresenceDataControllerForDelegate:(id)delegate
{
#if DEBUG
    NSLog(@"%@ paymentPresenceDataControllerForDelegate", self);
#endif
    NSParameterAssert([delegate conformsToProtocol:@protocol(NSFetchedResultsControllerDelegate)]);
    NSParameterAssert([delegate conformsToProtocol:@protocol(MCThisPaymentProtocol)]);
    MCPayment *thisPayment = [delegate thisPayment];
    // What entities will be fetched.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPaymentPresence"];
    // How to sort the data.
    [request setRelationshipKeyPathsForPrefetching:@[ @"person", @"payment", @"payment.currency", @"onWhichBill.mainCurrency", @"payment.exchangeRate" ]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO];
    NSArray *sortDescriptorArray = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptorArray];
    // Select only people from tonightsBill.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"payment = %@", thisPayment];
    [request setPredicate:predicate];
    
    // Create the FetchedResultsController.
    NSFetchedResultsController *dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_mainThreadContext sectionNameKeyPath:nil cacheName:nil];
    [dataController setDelegate:delegate];
    NSError *error;
    BOOL success = [dataController performFetch:&error];
    if (!success) {
        NSLog(@"Unable to fetch data for paymentPresenceDataController.");
    }
    return dataController;
}

- (NSFetchedResultsController *)availableCurrencyControllerForDelegate:(id)delegate
{
#if DEBUG
    NSLog(@"%@ availableCurrencyControllerForDelegate", self);
#endif
    NSParameterAssert([delegate conformsToProtocol:@protocol(NSFetchedResultsControllerDelegate)]);
    NSManagedObjectContext *context = [weAllPayStoreDocument managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCCurrency"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"isStillValid = YES"];
    request.fetchBatchSize = 20;
    NSFetchedResultsController *dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    dataController.delegate = delegate;
    NSError *fetchError;
    BOOL success = [dataController performFetch:&fetchError];
    if (!success) {
        NSLog(@"Error fetching available currencies: %@", fetchError);
    }
    return dataController;
}

- (NSFetchedResultsController *)searchCurrencyControllerWithSearchText:(NSString *)searchText withDelegate:(id)delegate
{
    NSParameterAssert([delegate conformsToProtocol:@protocol(NSFetchedResultsControllerDelegate)]);
    NSManagedObjectContext *context = [weAllPayStoreDocument managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCCurrency"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"isStillValid = YES AND name contains[c] %@", searchText];
    request.fetchBatchSize = 20;
    NSFetchedResultsController *dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    dataController.delegate = delegate;
    NSError *fetchError;
    BOOL success = [dataController performFetch:&fetchError];
    if (!success) {
        NSLog(@"Error fetching available currencies: %@", fetchError);
    }
    return dataController;
}

- (NSArray *)getPeopleOnSharedBill:(MCSharedBill *)thisBill
{
    // Should be run on the mainThread
    NSParameterAssert(thisBill);
    NSManagedObjectContext *context = _mainThreadContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
    NSSortDescriptor *sda = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    [request setSortDescriptors:@[sda]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY sharedBill = %@", thisBill];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (!result) {
        NSLog(@"Error fetching people: %@", error);
        return nil;
    } else {
        return result;
    }
}

- (NSArray *)getEmailaddressesFrom:(MCPerson *)thisPerson
{
    // Should be run on the mainThread
    NSParameterAssert(thisPerson);
    NSManagedObjectContext *context = _mainThreadContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCEmailAddress"];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"emailAddress" ascending:YES];
    [request setSortDescriptors:@[sd]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owner = %@", thisPerson];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (!result) {
        NSLog(@"Error fetching this person emailAddresses.");
        return nil;
    } else {
        return result;
    }
}

- (void)createCircularPeopleImages
{
    // Fetch all people.
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    NSError *fetchError;
    NSArray *allPeople = [_mainThreadContext executeFetchRequest:fetchRequest error:&fetchError];
    if (!allPeople) {
        NSLog(@"Error fetching all people: %@", fetchError);
    }
    // Insert a new base picture for every person in the database.
    for (MCPerson *person in allPeople) {
        [person setPictureDataFromImage:nil];
        [person setThumbnailDataFromImage:nil];
    }
    // Save everything.
    [self saveMainThreadContext];
}

#pragma mark - Inherited from super class

- (id)init
{
    self = [super init];
    
    static BOOL stillNeedsInit = 1;
    
    if (self && stillNeedsInit) {
//        [self openStore:nil];
        
        stillNeedsInit = 0;
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self defaultStore];
}

#pragma mark - Core Data Messages

- (void)startRespondingToStoreChangeNotifications
{
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self selector:@selector(storeWillSave:) name:NSManagedObjectContextWillSaveNotification object:_mainThreadContext];
    [dc addObserver:self selector:@selector(storeWillSave:) name:NSManagedObjectContextWillSaveNotification object:_backgroundThreadContext];
    [dc addObserver:self selector:@selector(storeDidSave:) name:NSManagedObjectContextDidSaveNotification object:_mainThreadContext];
    [dc addObserver:self selector:@selector(storeDidSave:) name:NSManagedObjectContextDidSaveNotification object:_backgroundThreadContext];
    [dc addObserver:self selector:@selector(storeWillBeSwapped:) name:NSPersistentStoreCoordinatorStoresWillChangeNotification object:_persistentStoreCoordinator];
    [dc addObserver:self selector:@selector(storeDidSwap:) name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:_persistentStoreCoordinator];
    [dc addObserver:self selector:@selector(storedidUpdateFromUbiquitousContainer:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:_persistentStoreCoordinator];
}

- (void)stopRespondingToStorechangeNotifications
{
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc removeObserver:self];
}

- (void)storeWillSave:(NSNotification *)notification
{
#if DEBUG
    NSLog(@"MCWeAllPayStoreController: Store will save.");
#endif
}

- (void)storeDidSave:(NSNotification *)notification
{
#if DEBUG
    NSLog(@"MCWeAllPayStoreController: Store did save.");
#endif
    if (notification.object != _mainThreadContext) {
        [_mainThreadContext performBlockAndWait:^{
#if DEBUG
            NSLog(@"Merging changes into mainContext.");
#endif
            [_mainThreadContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
    if (notification.object != _backgroundThreadContext) {
        [_backgroundThreadContext performBlockAndWait:^{
#if DEBUG
            NSLog(@"Merging changes into backgroundContext.");
#endif
            [_backgroundThreadContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

- (void)storeWillBeSwapped:(NSNotification *)notification
{
#if DEBUG
    NSLog(@"MCWeAllPayStoreController: Store will be swapped.");
#endif
    // Has main Context changes if yes save.
    [_mainThreadContext performBlockAndWait:^{
        if ([_mainThreadContext hasChanges]) {
            [self saveMainThreadContext];
        }
    // mainContext reset.
        [_mainThreadContext reset];
    }];
    // Has backgroundContext changes if yes save.
    [_backgroundThreadContext performBlockAndWait:^{
        if ([_backgroundThreadContext hasChanges]) {
            [self savebackgroundContext];
        }
    // backgroundContext reset.
        [_backgroundThreadContext reset];
    }];

}

- (void)storeDidSwap:(NSNotification *)notification
{
#if DEBUG
    NSLog(@"MCWeAllPayStoreController: Store did swap.");
#endif
}

- (void)storedidUpdateFromUbiquitousContainer:(NSNotification *)notification
{
#if DEBUG
    NSLog(@"MCWeAllPayStoreController: Store did update from Ubiquitous Container.");
#endif
    [_mainThreadContext performBlockAndWait:^{
        [_mainThreadContext mergeChangesFromContextDidSaveNotification:notification];
    }];
    [_backgroundThreadContext performBlockAndWait:^{
        [_backgroundThreadContext mergeChangesFromContextDidSaveNotification:notification];
    }];
}


#pragma mark - Core Data Stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)mainThreadContext
{
    if (_mainThreadContext != nil) {
        return _mainThreadContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _mainThreadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainThreadContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        [_mainThreadContext setPersistentStoreCoordinator:coordinator];
    }
#if DEBUG
    NSLog(@"mainThreadContext has been created.");
#endif
    return _mainThreadContext;
}

- (NSManagedObjectContext *)backgroundThreadContext
{
    if (_backgroundThreadContext != nil) {
        return _backgroundThreadContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _backgroundThreadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _backgroundThreadContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        [_backgroundThreadContext setPersistentStoreCoordinator:coordinator];
    }
#if DEBUG
    NSLog(@"backgroundThreadContext has been created.");
#endif
    return _backgroundThreadContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:MCWeAllPayStoreModelName withExtension:@"momd"];
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
    
    NSURL *directoryURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:MCWeAllPayStoreDirectoryName isDirectory:YES];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:directoryURL.path]) {
        NSError *directoryCreationError;
        if (![fileManager createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&directoryCreationError ]){
            NSLog(@"Unable to create base directory for WeAllPayStore: %@", directoryCreationError);
        }
    }
    NSURL *storeURL = [directoryURL URLByAppendingPathComponent:MCWeAllPayStoreFileName];
    
    NSError *error = nil;
    NSDictionary *storeOptions;
    if (isiCloudUsed == iCloudIsUsed) {
        NSLog(@"Store will be opened with iCloud support.");
        storeOptions = @{NSInferMappingModelAutomaticallyOption: @YES,
                         NSMigratePersistentStoresAutomaticallyOption: @YES,
                         NSPersistentStoreUbiquitousContentNameKey: MCiCloudWeAllPayStoreName};
    } else {
        NSLog(@"Store will not be opened with iCloud support.");
        storeOptions = @{NSInferMappingModelAutomaticallyOption: @YES,
                         NSMigratePersistentStoresAutomaticallyOption: @YES};
    }
//    if ([NSPersistentStoreCoordinator removeUbiquitousContentAndPersistentStoreAtURL:storeURL options:storeOptions error:&error]) {
//        NSLog(@"Error removing ubiquitous content: %@", error);
//    }
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
