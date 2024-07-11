//
//  MCPaymentPresence+addons.m
//  We all pay
//
//  Created by Mark Cornelisse on 07-05-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCPaymentPresence+addons.h"
#import "MCPayment+addons.h"
#import "MCSharedBill+addons.h"
#import "MCCurrency+addons.h"
#import "MCExchangeRate+CoreDataProperties.h"

#import "We_all_pay-Swift.h"

@implementation MCPaymentPresence (addons)

+ (void)deletePaymentPresence:(MCPaymentPresence *)paymentPresence
{
    [[paymentPresence managedObjectContext] deleteObject:paymentPresence];
}

- (NSNumber *)getAverageOweFromPaymentInMainCurrency
{
    double averageOweFromPaymentDouble = [[self averageOweFromPayment] doubleValue];
    double exchangeRateDouble = 0.0;
    exchangeRateDouble = [[[[self payment] exchangeRate] exchangeRate] doubleValue];
    return @(averageOweFromPaymentDouble * exchangeRateDouble);
}

@end
