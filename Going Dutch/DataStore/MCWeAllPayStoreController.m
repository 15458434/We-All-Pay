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

#import "MCTonightsBillTransfer.h"
#import "MCThisPaymentProtocol.h"

@implementation MCWeAllPayStoreController

@synthesize weAllPayStoreDocument;

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
    } /*else {
        if ([[sharedStore weAllPayStoreDocument] documentState] == UIDocumentStateClosed) {
            [[sharedStore weAllPayStoreDocument] openWithCompletionHandler:^(BOOL success){
                if (!success) {
                    NSLog(@"Something went wrong opening your document.");
                }
            }];
        }
    }*/
    return sharedStore;
}

- (void)openStore:(void (^)(BOOL success))completionHandler
{
    if (!weAllPayStoreDocument) {
        NSURL *weAllPayURL = [MCTools documentPathAsURLTo:@"WeAllPayStore"];
        weAllPayStoreDocument = [[UIManagedDocument alloc] initWithFileURL:weAllPayURL];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeIsReady:) name:UIDocumentStateChangedNotification object:weAllPayStoreDocument];
        
        // Auto migrate when possible.
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES,
                                  NSInferMappingModelAutomaticallyOption:@YES};
        [weAllPayStoreDocument setPersistentStoreOptions:options];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[[weAllPayStoreDocument fileURL] path]]) {
            [weAllPayStoreDocument saveToURL:[weAllPayStoreDocument fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                if (success) {
                    NSLog(@"Successful SaveForCreating");
                    [[weAllPayStoreDocument managedObjectContext] setUndoManager:[[NSUndoManager alloc] init]];
                    [[[weAllPayStoreDocument managedObjectContext] undoManager] disableUndoRegistration];
                    if (completionHandler) {
                        completionHandler(YES);
                    }
                } else {
                    NSLog(@"SaveForCreating not successful.");
                    if (completionHandler) {
                        completionHandler(NO);
                    }
                }
            }];
        } else if ([weAllPayStoreDocument documentState] == UIDocumentStateClosed) {
            [weAllPayStoreDocument openWithCompletionHandler:^(BOOL success) {
                if (success) {
                    NSLog(@"Succesful Open");
                    [[weAllPayStoreDocument managedObjectContext] setUndoManager:[[NSUndoManager alloc] init]];
                    [[[weAllPayStoreDocument managedObjectContext] undoManager] disableUndoRegistration];
                    if (completionHandler) {
                        completionHandler(YES);
                    }
                } else {
                    NSLog(@"Open not successful");
                    if (completionHandler) {
                        completionHandler(NO);
                    }
                }
            }];
        } else if ([weAllPayStoreDocument documentState] == UIDocumentStateNormal) {
            NSLog(@"DocumentState is already normal.");
            [[weAllPayStoreDocument managedObjectContext] setUndoManager:[[NSUndoManager alloc] init]];
            [[[weAllPayStoreDocument managedObjectContext] undoManager] disableUndoRegistration];
            if (completionHandler) {
                completionHandler(YES);
            }
        } else {
            NSLog(@"Something went wrong opening your document.");
            if ((completionHandler)) {
                completionHandler(NO);
            }
        }
    }
}

- (void)saveStore
{
    [weAllPayStoreDocument saveToURL:[weAllPayStoreDocument fileURL] forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (success) {
            NSLog(@"Succesfully saved.");
        } else {
            NSLog(@"Save not possible for document at %@", [weAllPayStoreDocument fileURL]);
        }
    }];
    // Basically does the same as the original saveStore code. However now a more useful error message is logged.
//    NSManagedObjectContext *context = [weAllPayStoreDocument managedObjectContext];
//    NSError *error;
//    BOOL succes = [context save:&error];
//    if (succes) {
//        NSLog(@"Succesfully saved.");
//    } else {
//        NSLog(@"Save not possible for document at %@", [weAllPayStoreDocument fileURL]);
//        NSLog(@"Save not possible: %@", [error localizedDescription]);
//    }
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
    NSManagedObjectContext *context = [weAllPayStoreDocument managedObjectContext];
    [[context undoManager] enableUndoRegistration];
    [[context undoManager] beginUndoGrouping];
}

- (void)beginUndoGroupWithoutRegistration
{
    NSManagedObjectContext *context = [weAllPayStoreDocument managedObjectContext];
    [[context undoManager] beginUndoGrouping];
}

- (void)endUndoGroup
{
    NSManagedObjectContext *context = [weAllPayStoreDocument managedObjectContext];
    [[context undoManager] endUndoGrouping];
    [[context undoManager] disableUndoRegistration];
}

- (void)endUndoGroupWithoutRegistration
{
    NSManagedObjectContext *context = [weAllPayStoreDocument managedObjectContext];
    [[context undoManager] endUndoGrouping];
}

- (void)endUndoGroupAndProcess
{
    NSManagedObjectContext *context = [weAllPayStoreDocument managedObjectContext];
    [[context undoManager] endUndoGrouping];
    [[context undoManager] disableUndoRegistration];
    [context processPendingChanges];
}

- (void)endUndoGroupAndUndo
{
    NSManagedObjectContext *context = [weAllPayStoreDocument managedObjectContext];
    [[context undoManager] endUndoGrouping];
    [[context undoManager] undoNestedGroup];
    [[context undoManager] disableUndoRegistration];
}

#pragma mark - TableView fill sources.

- (NSFetchedResultsController *)allTripsDataControllerForDelegate:(id)delegate
{
    NSParameterAssert([delegate conformsToProtocol:@protocol(NSFetchedResultsControllerDelegate)]);
    NSManagedObjectContext *context = [weAllPayStoreDocument managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCSharedBill"];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO]]];
    [request setRelationshipKeyPathsForPrefetching:@[ @"payments", @"peoplePresent" ]];
    NSFetchedResultsController *dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                         managedObjectContext:context
                                                           sectionNameKeyPath:nil
                                                                    cacheName:nil];
    [dataController setDelegate:delegate];
    
    return dataController;
}

- (NSFetchedResultsController *)sharedBillPaymentsDataControllerForDelegate:(id)delegate
{
    NSParameterAssert([delegate conformsToProtocol:@protocol(NSFetchedResultsControllerDelegate)]);
    NSParameterAssert([delegate conformsToProtocol:@protocol(MCTonightsBillGet)]);
    NSManagedObjectContext *context = [weAllPayStoreDocument managedObjectContext];
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
    
    NSString *cacheName = [NSString stringWithFormat:@"All payments cache of trip: %@", [tonightsBill tripName]];
    // Create the FetchedResultsController.
    NSFetchedResultsController *dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:cacheName];
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
    NSParameterAssert([delegate conformsToProtocol:@protocol(MCTonightsBillGet)]);
    NSManagedObjectContext *context = [weAllPayStoreDocument managedObjectContext];
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
    NSFetchedResultsController *dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:[NSString stringWithFormat:@"All persons cache of trip: %@", [tonightsBill uniqueBillId]]];
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
    NSManagedObjectContext *context = [weAllPayStoreDocument managedObjectContext];
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
    NSFetchedResultsController *dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:[NSString stringWithFormat:@"All payment presence cache for payment: %@", [thisPayment uniquePaymentId]]];
//    [dataController setDelegate:delegate];
    NSError *error;
    BOOL success = [dataController performFetch:&error];
    if (!success) {
        NSLog(@"Something went wrong");
    }
    return dataController;
}

- (NSArray *)getPeopleOnSharedBill:(MCSharedBill *)thisBill
{
    NSParameterAssert(thisBill);
    NSManagedObjectContext *context = [weAllPayStoreDocument managedObjectContext];
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
    NSParameterAssert(thisPerson);
    NSManagedObjectContext *context = [weAllPayStoreDocument managedObjectContext];
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
        [self openStore:nil];
        
        stillNeedsInit = 0;
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self defaultStore];
}

@end
