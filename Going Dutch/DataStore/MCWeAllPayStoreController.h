//
//  MCWeAllPayStoreController.h
//  We all pay
//
//  Created by Mark Cornelisse on 08-07-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import Foundation;
@import CoreData;

@class MCPayment;
@class MCPerson;
@class MCSharedBill;
@class MCExchangeRate;

/*
The We All Pay Store Controller is designed to do writing in the background and fetching on the mainThread. This way write actions won't interfere with the user interface.
 */

@interface MCWeAllPayStoreController : NSObject

@property (nonatomic, strong, readonly) UIManagedDocument *weAllPayStoreDocument;
@property (nonatomic, strong, readonly) NSManagedObjectContext *mainThreadContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *backgroundThreadContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;

+ (MCWeAllPayStoreController *)defaultStore;
+ (void)prepareCurrencyStoreIfNecessary;

- (BOOL)isDocumentStateNormal;

- (void)openStore:(void (^)(BOOL success))completionHandler;
- (void)saveMainThreadContext;
- (void)savebackgroundContext;
- (void)closeDocument;

- (void)beginUndoGroup;
- (void)beginUndoGroupWithoutRegistration;
- (void)endUndoGroup;
- (void)endUndoGroupWithoutRegistration;
- (void)endUndoGroupAndProcess;
- (void)endUndoGroupAndProcessWithoutRegistration;
- (void)endUndoGroupAndUndo;
- (void)endUndoGroupAndUndoWithoutRegistration;

#pragma mark - Webinterface

- (void)updateXRate:(MCExchangeRate *)exchangeRate withCompletionHandler:(void (^)(NSDictionary *exchangeRateResult))completionBlock;

#pragma mark - TableViewSources
- (NSFetchedResultsController *)allTripsDataControllerForDelegate:(id)delegate;
- (NSFetchedResultsController *)sharedBillPaymentsDataControllerForDelegate:(id)delegate;
- (NSFetchedResultsController *)sharedBillPeoplePresentDataControllerForDelegate:(id)delegate;
- (NSFetchedResultsController *)paymentPresenceDataControllerForDelegate:(id)delegate;
- (NSFetchedResultsController *)availableCurrencyControllerForDelegate:(id)delegate;
- (NSFetchedResultsController *)searchCurrencyControllerWithSearchText:(NSString *)searchText withDelegate:(id)delegate;
- (NSArray *)getPeopleOnSharedBill:(MCSharedBill *)thisBill;
- (NSArray *)getEmailaddressesFrom:(MCPerson *)thisPerson;

@end
