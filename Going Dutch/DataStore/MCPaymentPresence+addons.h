//
//  MCPaymentPresence+addons.h
//  We all pay
//
//  Created by Mark Cornelisse on 07-05-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCPaymentPresence+CoreDataProperties.h"

@interface MCPaymentPresence (addons)

+ (void)deletePaymentPresence:(MCPaymentPresence *)paymentPresence;

- (NSNumber *)getAverageOweFromPaymentInMainCurrency;


@end
