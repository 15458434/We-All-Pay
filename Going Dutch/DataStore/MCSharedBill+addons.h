//
//  MCSharedBill+addons.h
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBill+CoreDataProperties.h"

@class MCExchangeRate;

@interface MCSharedBill (addons)

+ (MCSharedBill *)addSharedBillToContext:(NSManagedObjectContext *)context;

+ (void)deleteSharedbill:(MCSharedBill *)deleteBill;

+ (MCSharedBill *)fetchSharedBillWithUniqueId:(NSString *)uuid inContext:(NSManagedObjectContext *)context;
+ (BOOL)isTableInDatabaseEmpty;
+ (BOOL)isTableInDatabaseEmptyForContext:(NSManagedObjectContext *)context;

- (void)deletePayment:(MCPayment *)toBeDeletePayment;
- (void)updatePaymentForSupportWithPaymentPresence;

- (void)deletePerson:(MCPerson *)toBeDeletedPerson;
- (MCPerson *)fetchPersonWithUniqueID:(NSString *)uuid;
- (BOOL)isPresentWithFirstName:(NSString *)firstName andLastName:(NSString *)lastName andEmailAddress:(NSString *)emailAddress;
- (BOOL)areTherePeople;
- (NSUInteger)totalAmountOfPeoplePresent;
- (NSUInteger)totalAmountOfPeopleWhoHavePaid;

- (BOOL)doAllPaymentsHaveAPayer;
- (MCPayment *)getFirstPaymentWithoutAPayer;
- (BOOL)areAllExchangeRatesValid;
- (void)updateMainCurrencyFromCode:(NSString *)code withCompletion:(void (^)(NSError *error))completion;
- (NSArray<MCExchangeRate *> *)fetchAllExchangeRatesWithError:(NSError **)error __deprecated;
- (void)updateAllExchangeRatesWithCompletionHandler:(void (^)(NSError *error))completion __deprecated;
- (NSArray *)solveWhoHasToPayWhoFromThisBill;
- (void)solveWithHandler:(void (^)(NSArray *results, NSError *error))solution;
- (NSNumber *)totalSumOfMoneyOfThisSharedBill;
- (NSArray<MCPerson *> *)fetchPeoplePresentOrderedByAmountPaid:(BOOL)ascending;
- (NSNumber *)totalAmountOfCreditBy:(MCPerson *)person;
- (NSNumber *)totalSumPaidBy:(MCPerson *)person;
- (NSNumber *)amountPeopleShouldHavePaid;
- (NSNumber *)amountShouldHavePaidBy:(MCPerson *)person;
- (BOOL)hasPersonPaidSomething:(MCPerson *)person;
- (BOOL)doesEveryoneHaveAnEmailAddress;

- (NSArray<MCPerson *> *)getArrayOfPeopleSortedOnFullNames;

- (void)deleteIfStillNew;

- (NSArray<MCCurrency *>*)recentUsedForeignCurrencies:(NSUInteger)fetchLimit;

@end
