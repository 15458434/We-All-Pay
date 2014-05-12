//
//  MCWeAllPayStoreController.h
//  We all pay
//
//  Created by Mark Cornelisse on 08-07-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MCPayment;
@class MCPerson;
@class MCSharedBill;

@interface MCWeAllPayStoreController : NSObject
{
    
}

@property (nonatomic, strong, readonly) UIManagedDocument *weAllPayStoreDocument;

+ (MCWeAllPayStoreController *)defaultStore;

- (BOOL)isDocumentStateNormal;

- (void)openStore:(void (^)(BOOL success))completionHandler;
- (void)saveStore;
- (void)closeDocument;

- (void)beginUndoGroup;
- (void)beginUndoGroupWithoutRegistration;
- (void)endUndoGroup;
- (void)endUndoGroupWithoutRegistration;
- (void)endUndoGroupAndProcess;
- (void)endUndoGroupAndUndo;

// TableView fill sources.
- (NSFetchedResultsController *)allTripsDataControllerForDelegate:(id)delegate;
- (NSFetchedResultsController *)sharedBillPaymentsDataControllerForDelegate:(id)delegate;
- (NSFetchedResultsController *)sharedBillPeoplePresentDataControllerForDelegate:(id)delegate;
- (NSFetchedResultsController *)paymentPresenceDataControllerForDelegate:(id)delegate;
- (NSArray *)getPeopleOnSharedBill:(MCSharedBill *)thisBill;
- (NSArray *)getEmailaddressesFrom:(MCPerson *)thisPerson;

@end
