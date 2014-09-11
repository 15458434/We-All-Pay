//
//  MCWeAllPayStoreController.m
//  We all pay
//
//  Created by Mark Cornelisse on 08-07-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCWeAllPayStoreController.h"

#import "MCPerson.h"
#import "MCPayment.h"
#import "MCSharedBill.h"
#import "MCCurrency+addons.h"
#import "MCExchangeRate+addons.h"

#import "MCxRatesController.h"
#import "XRCurrencyStoreController.h"

#import "MCTonightsBillTransfer.h"
#import "MCThisPaymentProtocol.h"

// This is the name of the WeAllPayStoreFile. It's inherited from the location where UIManagedDocumentStores it's database file.
NSString * const MCWeAllPayStoreFileName = @"persistentStore";
NSString * const MCWeAllPayStoreDirectoryName = @"WeAllPayStore/StoreContent";
// File of the WeAllPayStore Database model file.
NSString * const MCWeAllPayStoreModelName = @"WeAllPayStore";

NSString * const MCiCloudWeAllPayStoreName = @"iCloud-WeAllPayStore";

@interface MCWeAllPayStoreController ()

@property (nonatomic, strong) MCxRatesController *xRatesfetchController;
@property (nonatomic, strong) NSMutableArray *exchangeRateQueue;

@end

@implementation MCWeAllPayStoreController

@synthesize weAllPayStoreDocument;

@synthesize managedObjectModel = _managedObjectModel;
@synthesize mainThreadContext = _mainThreadContext;
@synthesize backgroundThreadContext = _backgroundThreadContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Internal methods



#pragma mark - New in this class

+ (void)prepareCurrencyStoreIfNecessary
{
    NSOperationQueue *someQueue = [NSOperationQueue new];
    [someQueue addOperationWithBlock:^{
        if (![XRCurrencyStoreController doesMyCurrencyDatabaseFileExist]) {
            XRCurrencyStoreController *defaultCurrencyStore = [XRCurrencyStoreController sharedStore];
            [defaultCurrencyStore prepareStoreWithCompletionHandler:^{
                NSLog(@"CurrencyStore available.");
            }];
        }
    }];
}

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
//    if (!weAllPayStoreDocument) {
//        NSURL *weAllPayURL = [MCTools documentPathAsURLTo:@"WeAllPayStore"];
//        weAllPayStoreDocument = [[UIManagedDocument alloc] initWithFileURL:weAllPayURL];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeIsReady:) name:UIDocumentStateChangedNotification object:weAllPayStoreDocument];
//        
//        // Auto migrate when possible.
//        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES,
//                                  NSInferMappingModelAutomaticallyOption:@YES};
//        [weAllPayStoreDocument setPersistentStoreOptions:options];
//        
//        if (![[NSFileManager defaultManager] fileExistsAtPath:[[weAllPayStoreDocument fileURL] path]]) {
//            [weAllPayStoreDocument saveToURL:[weAllPayStoreDocument fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
//                if (success) {
//                    NSLog(@"Successful SaveForCreating");
//                    // Add all availableCurrencies to the we all pay store when you're creating.
//                    [MCCurrency addAllAvailableCurrenciesToContext:[weAllPayStoreDocument managedObjectContext]];
//                    [[weAllPayStoreDocument managedObjectContext] setUndoManager:[[NSUndoManager alloc] init]];
//                    [[[weAllPayStoreDocument managedObjectContext] undoManager] disableUndoRegistration];
//                    if (completionHandler) {
//                        completionHandler(YES);
//                    }
//                } else {
//                    NSLog(@"SaveForCreating not successful.");
//                    if (completionHandler) {
//                        completionHandler(NO);
//                    }
//                }
//            }];
//        } else if ([weAllPayStoreDocument documentState] == UIDocumentStateClosed) {
//            [weAllPayStoreDocument openWithCompletionHandler:^(BOOL success) {
//                if (success) {
//                    NSLog(@"Succesful Open");
//                    [[weAllPayStoreDocument managedObjectContext] setUndoManager:[[NSUndoManager alloc] init]];
//                    [[[weAllPayStoreDocument managedObjectContext] undoManager] disableUndoRegistration];
//                    if (completionHandler) {
//                        completionHandler(YES);
//                    }
//                } else {
//                    NSLog(@"Open not successful");
//                    if (completionHandler) {
//                        completionHandler(NO);
//                    }
//                }
//            }];
//        } else if ([weAllPayStoreDocument documentState] == UIDocumentStateNormal) {
//            NSLog(@"DocumentState is already normal.");
//            [[weAllPayStoreDocument managedObjectContext] setUndoManager:[[NSUndoManager alloc] init]];
//            [[[weAllPayStoreDocument managedObjectContext] undoManager] disableUndoRegistration];
//            if (completionHandler) {
//                completionHandler(YES);
//            }
//        } else {
//            NSLog(@"Something went wrong opening your document.");
//            if ((completionHandler)) {
//                completionHandler(NO);
//            }
//        }
//        _mainThreadContext = [weAllPayStoreDocument managedObjectContext];
//    }
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
//    [self saveStore];
//    NSError *saveError;
//    BOOL saveSuccesful = [context save:&saveError];
//    if (!saveSuccesful) {
//        NSLog(@"Save unsuccesful: %@", [saveError localizedDescription]);
//    }
}

- (void)endUndoGroupAndProcessWithoutRegistration
{
    [[_mainThreadContext undoManager] endUndoGrouping];
    [_mainThreadContext processPendingChanges];
//    [self saveStore];
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

- (MCxRatesController *)xRatesfetchController
{
    if (!_xRatesfetchController) {
        _xRatesfetchController = [MCxRatesController new];
    }
    return _xRatesfetchController;
}

#pragma mark - Webinterface

- (void)updateXRate:(MCExchangeRate *)exchangeRate withCompletionHandler:(void (^)(NSDictionary *))completionBlock
{
    NSString *fromCode = [[exchangeRate fromCurrency] code];
    NSString *toCode = [[exchangeRate toCurrency] code];
    if (!_exchangeRateQueue) {
        _exchangeRateQueue = [NSMutableArray new];
    }
    [_exchangeRateQueue addObject:exchangeRate];
    __weak __typeof(self) weakSelf = self;
    [[self xRatesfetchController] getExchangeRateFrom:fromCode to:toCode withCompletionHandler:^(NSDictionary *exchangeRateResult) {
        NSLog(@"Fetched ExchangeRate: %@", exchangeRateResult);
        __strong __typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            [exchangeRate setExchangeRate:[exchangeRateResult objectForKey:MCCurrencyExchangeRate]];
            [exchangeRate setSource:[exchangeRateResult objectForKey:MCSource]];
        } else {
            NSLog(@"Default Controller does not exist anymore.");
        }
        [[strongSelf exchangeRateQueue] removeObject:exchangeRate];
        completionBlock(exchangeRateResult);
    }];
}

#pragma mark - TableView fill sources.

- (NSFetchedResultsController *)allTripsDataControllerForDelegate:(id)delegate
{
    NSParameterAssert([delegate conformsToProtocol:@protocol(NSFetchedResultsControllerDelegate)]);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCSharedBill"];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO]]];
    [request setRelationshipKeyPathsForPrefetching:@[ @"payments", @"peoplePresent" ]];
    NSFetchedResultsController *dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                         managedObjectContext:_mainThreadContext
                                                           sectionNameKeyPath:nil
                                                                    cacheName:nil];
    [dataController setDelegate:delegate];
    
    return dataController;
}

- (NSFetchedResultsController *)sharedBillPaymentsDataControllerForDelegate:(id)delegate
{
    NSParameterAssert([delegate conformsToProtocol:@protocol(NSFetchedResultsControllerDelegate)]);
    NSParameterAssert([delegate conformsToProtocol:@protocol(MCTonightsBillTransfer)]);
    MCSharedBill *tonightsBill = [delegate tonightsBill];
    // What entities will be fetched.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPayment"];
    [request setRelationshipKeyPathsForPrefetching:@[ @"payingPerson" ]];
    // How to sort the data.
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO];
    NSArray *sortDescriptorArray = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptorArray];
    // Select only people from tonightsBill.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"onWhichBill = %@", tonightsBill];
    [request setPredicate:predicate];
    
    // Create the FetchedResultsController.
    NSFetchedResultsController *dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_mainThreadContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    BOOL success = [dataController performFetch:&error];
    if (!success) {
        NSLog(@"Something went wrong fetching the payments");
    }
    [dataController setDelegate:delegate];
    return dataController;
}

- (NSFetchedResultsController *)sharedBillPeoplePresentDataControllerForDelegate:(id)delegate
{
    NSParameterAssert([delegate conformsToProtocol:@protocol(NSFetchedResultsControllerDelegate)]);
    NSParameterAssert([delegate conformsToProtocol:@protocol(MCTonightsBillTransfer)]);
    MCSharedBill *tonightsBill = [delegate tonightsBill];
    // What entities will be fetched.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
    // How to sort the data.
    [request setRelationshipKeyPathsForPrefetching:@[ @"emailAddress", @"payments", @"sharedBill" ]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO];
    NSArray *sortDescriptorArray = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptorArray];
    // Select only people from tonightsBill.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY sharedBill = %@", tonightsBill];
    [request setPredicate:predicate];
    
    // Create the FetchedResultsController.
    NSFetchedResultsController *dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_mainThreadContext sectionNameKeyPath:nil cacheName:nil];
    [dataController setDelegate:delegate];
    NSError *error;
    BOOL success = [dataController performFetch:&error];
    if (!success) {
        NSLog(@"Something went wrong");
    }
    return dataController;
}

- (NSFetchedResultsController *)paymentPresenceDataControllerForDelegate:(id)delegate
{
    NSParameterAssert([delegate conformsToProtocol:@protocol(NSFetchedResultsControllerDelegate)]);
    NSParameterAssert([delegate conformsToProtocol:@protocol(MCThisPaymentProtocol)]);
    MCPayment *thisPayment = [delegate thisPayment];
    // What entities will be fetched.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPaymentPresence"];
    // How to sort the data.
    [request setRelationshipKeyPathsForPrefetching:@[ @"person", @"payment" ]];
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
        NSLog(@"Something went wrong");
    }
    return dataController;
}

- (NSFetchedResultsController *)availableCurrencyControllerForDelegate:(id)delegate
{
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
        NSLog(@"Error fetching available currencies: %@", [fetchError localizedDescription]);
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
        NSLog(@"Error fetching available currencies: %@", [fetchError localizedDescription]);
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
        NSLog(@"Error fetching people: %@", [error localizedDescription]);
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
    NSLog(@"MCWeAllPayStoreController: Store will save.");
}

- (void)storeDidSave:(NSNotification *)notification
{
    NSLog(@"MCWeAllPayStoreController: Store did save.");
    if (notification.object != _mainThreadContext) {
        [_mainThreadContext performBlockAndWait:^{
            NSLog(@"Merging changes into mainContext.");
            [_mainThreadContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
    if (notification.object != _backgroundThreadContext) {
        [_backgroundThreadContext performBlockAndWait:^{
            NSLog(@"Merging changes into backgroundContext.");
            [_backgroundThreadContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

- (void)storeWillBeSwapped:(NSNotification *)notification
{
    NSLog(@"MCWeAllPayStoreController: Store will be swapped.");
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
    NSLog(@"MCWeAllPayStoreController: Store did swap.");
}

- (void)storedidUpdateFromUbiquitousContainer:(NSNotification *)notification
{
    NSLog(@"MCWeAllPayStoreController: Store did update from Ubiquitous Container.");
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
//    NSDictionary *storeOptions = @{NSInferMappingModelAutomaticallyOption: @YES,
//                                   NSMigratePersistentStoresAutomaticallyOption: @YES};
    NSDictionary *storeOptions = @{NSInferMappingModelAutomaticallyOption: @YES,
                                   NSMigratePersistentStoresAutomaticallyOption: @YES,
                                   NSPersistentStoreUbiquitousContentNameKey : MCiCloudWeAllPayStoreName};
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
