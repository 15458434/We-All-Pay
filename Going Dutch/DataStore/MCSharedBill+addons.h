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
- (BOOL)isPresentWithFirstName:(NSString *)firstName andLastName:(NSString *)lastName andEmailAddress:(NSString *)emailAddress;
- (BOOL)areTherePeople;
- (NSUInteger)totalAmountOfPeoplePresent;
- (NSUInteger)totalAmountOfPeopleWhoHavePaid;

- (BOOL)areAllExchangeRatesValid;
- (void)updateInvalidExchangeRatesWithCompletionBlock:(void (^)(NSArray *results))completionBlock;
- (NSArray *)solveWhoHasToPayWhoFromThisBill;
- (NSArray *)solveWhoHasToPayWhoFromThisBillWithCompletionBlock:(void (^)(NSArray *))completionBlock;
- (NSNumber *)totalSumOfMoneyOfThisSharedBill;
- (NSString *)totalSumOfMoneyOfThisSharedBillAsCurrencyString;
- (NSNumber *)totalSumPaidBy:(MCPerson *)person;
- (NSArray *)fetchPeoplePresentOrderedByAmountPaid:(BOOL)ascending;
- (NSNumber *)totalAmountOfCreditBy:(MCPerson *)person;
- (NSNumber *)amountPeopleShouldHavePaid;
- (NSString *)amountPeopleShouldHavePaidAsCurrencyString;
- (NSNumber *)amountShouldHavePaidBy:(MCPerson *)person;
- (NSString *)amountShouldHavePaidAsCurrencyStringBy:(MCPerson *)person;
- (BOOL)hasPersonPaidSomething:(MCPerson *)person;
- (BOOL)doesEveryoneHaveAnEmailAddress;

- (NSArray *)getArrayOfFullNamesOfPeoplePresent;

- (void)deleteIfStillNew;

@end
