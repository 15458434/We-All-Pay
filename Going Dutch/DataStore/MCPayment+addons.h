//
//  MCPayment+addons.h
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPayment+CoreDataProperties.h"

@class MCPaymentPresence;

NS_ASSUME_NONNULL_BEGIN

@interface MCPayment (addons)

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
- (NSNumber *)moneyInMainCurrency;
- (MCExchangeRate *)addExchangeRate;
- (void)setNewCurrencyAndAutomaticallyUpdateExchangeRate:(MCCurrency *)newCurrency withCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler;

- (NSString *)fullDescriptionOfPayment;

@end

NS_ASSUME_NONNULL_END
