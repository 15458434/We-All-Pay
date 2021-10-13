//
//  MCPerson.m
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import FirebaseCrashlytics;

#import "MCPerson.h"
#import "MCEmailAddress.h"
#import "MCPayment.h"
#import "MCPaymentPresence.h"
#import "MCSharedBill.h"

@implementation MCPerson

//- (void)addPaymentsObject:(MCPayment *)value {
//    NSDictionary *valueAsDictionary = [value dictionaryWithValuesForKeys:@[@"categoryId", @"descriptionOfPayment", @"money", @"moneyInMainCurrency", @"uniquePaymentId"]];
//    [FIRCrashlytics.crashlytics logWithFormat:@"The current value given is %@", valueAsDictionary];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniquePaymentId = %@", value.uniquePaymentId];
//    NSSet *filteredForValue = [self.payments filteredSetUsingPredicate:predicate];
//    if (filteredForValue.count == 0) {
//        NSSet *result = [self.payments setByAddingObject:value];
//        self.payments = result;
//    } 
//}

@end
