//
//  MCPaymentPresence+addons.h
//  We all pay
//
//  Created by Mark Cornelisse on 07-05-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCPaymentPresence.h"

@interface MCPaymentPresence (addons)

+ (MCPaymentPresence *)addPaymentPresence;
+ (MCPaymentPresence *)addPaymentPresenceInContext:(NSManagedObjectContext *)context;
+ (void)deletePaymentPresence:(MCPaymentPresence *)paymentPresence;

- (NSString *)getCurrencyStringOfAverageOwe __deprecated;
- (NSNumber *)getAverageOweFromPaymentInMainCurrency;


@end
