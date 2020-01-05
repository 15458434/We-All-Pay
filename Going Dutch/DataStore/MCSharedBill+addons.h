//
//  MCSharedBill+addons.h
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBill.h"
#import "MCPerson+addons.h"

@interface MCSharedBill (addons)

+ (MCSharedBill *)addSharedBill;
+ (MCSharedBill *)addSharedBillToContext:(NSManagedObjectContext *)context;

+ (void)deleteSharedbill:(MCSharedBill *)deleteBill;

+ (MCSharedBill *)fetchSharedBillWithUniqueId:(NSString *)uuid inContext:(NSManagedObjectContext *)context;
+ (BOOL)isTableInDatabaseEmpty;
+ (BOOL)isTableInDatabaseEmptyForContext:(NSManagedObjectContext *)context;

- (NSString *)stringOfApproxPeoplePresent;
- (NSString *)stringOfApproxPeoplePresentWithFullNames;

- (MCPayment *)addPayment;
- (void)deletePayment:(MCPayment *)toBeDeletePayment;
- (void)updatePaymentForSupportWithPaymentPresence;

- (MCPerson *)addPerson;
- (void)deletePerson:(MCPerson *)toBeDeletedPerson;
- (MCPerson *)fetchPersonWithUniqueID:(NSString *)uuid;
- (BOOL)isPresentWithFirstName:(NSString *)firstName andLastName:(NSString *)lastName andEmailAddress:(NSString *)emailAddress;
- (BOOL)areTherePeople;
- (NSUInteger)totalAmountOfPeoplePresent;
- (NSUInteger)totalAmountOfPeopleWhoHavePaid;

- (BOOL)doAllPaymentHaveAPayer;
- (MCPayment *)getFirstPaymentWithoutAPayer;
- (BOOL)areAllExchangeRatesValid;
- (void)updateMainCurrencyFromCode:(NSString *)code withCompletion:(void (^)(NSError *error))completion;
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
