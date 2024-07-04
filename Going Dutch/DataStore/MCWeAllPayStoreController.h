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

@property (nonatomic, strong, readonly, nullable) NSError *error;

@property (nonatomic, strong, readonly) NSManagedObjectContext *viewContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, strong, readonly) ExchangeRateFetcher *fetcher;

+ (instancetype)defaultStore;

#ifdef SCREENSHOTS
- (void)openStore:(void (^_Nullable)(MCWeAllPayStoreController *store, BOOL success))completionHandler;
#else
- (void)openStore;
#endif
- (void)performBackgroundTask:(void (^)(NSManagedObjectContext *))block;
- (void)saveViewContext;

- (void)beginUndoGroup;
- (void)beginUndoGroupWithoutRegistration;
- (void)endUndoGroup;
- (void)endUndoGroupWithoutRegistration;
- (void)endUndoGroupAndProcess;
- (void)endUndoGroupAndProcessWithoutRegistration;
- (void)endUndoGroupAndUndo;
- (void)endUndoGroupAndUndoWithoutRegistration;

- (void)resetError;

@end

NS_ASSUME_NONNULL_END
