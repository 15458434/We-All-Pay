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
@class ExchangeRateFetcher;

/*
The We All Pay Store Controller is designed to do writing in the background and fetching on the mainThread. This way write actions won't interfere with the user interface.
 */

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
@interface MCWeAllPayStoreController : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *mainThreadContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *backgroundThreadContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, strong, readonly) ExchangeRateFetcher *fetcher;

+ (instancetype)defaultStore;

#ifdef SCREENSHOTS
- (void)openStore:(void (^_Nullable)(MCWeAllPayStoreController *store, BOOL success))completionHandler;
#else
- (void)openStore:(void (^_Nullable)(BOOL success))completionHandler;
#endif
- (void)saveMainThreadContext;
- (void)savebackgroundContext;

- (void)beginUndoGroup;
- (void)beginUndoGroupWithoutRegistration;
- (void)endUndoGroup;
- (void)endUndoGroupWithoutRegistration;
- (void)endUndoGroupAndProcess;
- (void)endUndoGroupAndProcessWithoutRegistration;
- (void)endUndoGroupAndUndo;
- (void)endUndoGroupAndUndoWithoutRegistration;

#pragma mark - TableViewSources
- (NSFetchedResultsController *)allTripsDataControllerForDelegate:(id)delegate __deprecated;
- (NSFetchedResultsController *)sharedBillPaymentsDataControllerForDelegate:(id)delegate __deprecated;
- (NSFetchedResultsController *)sharedBillPeoplePresentDataControllerForDelegate:(id)delegate __deprecated;
- (NSFetchedResultsController *)paymentPresenceDataControllerForDelegate:(id)delegate __deprecated;
- (NSFetchedResultsController *)availableCurrencyControllerForDelegate:(id)delegate __deprecated;
- (NSFetchedResultsController *)searchCurrencyControllerWithSearchText:(NSString *)searchText withDelegate:(id)delegate __deprecated;
- (NSArray *)getPeopleOnSharedBill:(MCSharedBill *)thisBill __deprecated;
- (NSArray *)getEmailaddressesFrom:(MCPerson *)thisPerson __deprecated;

@end

NS_ASSUME_NONNULL_END
