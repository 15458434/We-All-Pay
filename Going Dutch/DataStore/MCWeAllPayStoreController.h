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
@class MCExchangeRate;

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
- (NSArray *)getPeopleOnSharedBill:(MCSharedBill *)thisBill;
- (NSArray *)getEmailaddressesFrom:(MCPerson *)thisPerson;

@end
