//
//  MCPayment+addons.h
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPayment.h"

@class MCPaymentPresence;

@interface MCPayment (addons)

+ (MCPayment *)addPayment;
+ (MCPayment *)addPaymentInContext:(NSManagedObjectContext *)context;

+ (void)deletePayment:(MCPayment *)payment;

+ (MCPayment *)fetchPaymentWithUniqueId:(NSString *)uuid;
+ (MCPayment *)fetchPaymentWithUniqueId:(NSString *)uuid fromContext:(NSManagedObjectContext *)context;
+ (BOOL)isTableInDatabaseEmpty;
+ (BOOL)isTableInDatabaseEmptyForContext:(NSManagedObjectContext *)context;

- (BOOL)hasPayer;

- (void)addPaymentPresenceFor:(MCPerson *)person;
- (void)addLateArrivalPaymentPresenceFor:(MCPerson *)person;

- (MCPaymentPresence *)fetchPaymentPresenceForPerson:(MCPerson *)person;
- (void)thisPerson:(MCPerson *)person setIsPresent:(NSNumber *)isPresent;
- (NSNumber *)peoplePresentOnThisPayment;
- (NSNumber *)averageAmountPeopleShouldHavePaidOnThisPayment;
- (void)recalculateAveragePeopleOweAndStore;
- (NSString *)getMoneyValueAsAString;
- (NSString *)getMoneyValueInCurrencyAsAString;
- (void)putMoneyValueAsAString:(NSString *)moneyString;
- (void)putMoneyValueInCurrencyAsAString:(NSString *)moneyString;
- (NSNumber *)moneyInMainCurrency;
- (MCExchangeRate *)addExchangeRate;
- (void)setNewCurrencyAndAutomaticallyUpdateExchangeRate:(MCCurrency *)newCurrency;

@end
