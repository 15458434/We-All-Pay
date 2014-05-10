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
+ (void)deletePayment:(MCPayment *)payment;

+ (MCPayment *)fetchPaymentWithUniqueId:(NSString *)uuid;
+ (BOOL)isTableInDatabaseEmpty;

- (BOOL)hasPayer;

- (MCPaymentPresence *)fetchPaymentPresenceForPerson:(MCPerson *)person;
- (void)thisPerson:(MCPerson *)person setIsPresent:(NSNumber *)isPresent;
- (NSNumber *)peoplePresentOnThisPayment;
- (NSNumber *)averageAmountPeopleShouldHavePaidOnThisPayment;
- (void)recalculateAveragePeopleOweAndStore;
- (NSString *)getMoneyValueAsAString;
- (NSString *)getMoneyValueInCurrencyAsAString;
- (void)putMoneyValueAsAString:(NSString *)moneyString;
- (void)putMoneyValueInCurrencyAsAString:(NSString *)moneyString;

@end
