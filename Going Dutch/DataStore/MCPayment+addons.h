//
//  MCPayment+addons.h
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPayment.h"

@interface MCPayment (addons)

+ (MCPayment *)addPayment;
+ (void)deletePayment:(MCPayment *)payment;

+ (MCPayment *)fetchPaymentWithUniqueId:(NSString *)uuid;
+ (BOOL)isTableInDatabaseEmpty;

- (BOOL)hasPayer;

@end
