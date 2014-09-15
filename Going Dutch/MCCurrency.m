//
//  MCCurrency.m
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCCurrency.h"
#import "MCExchangeRate.h"
#import "MCPayment.h"
#import "MCSharedBill.h"


@implementation MCCurrency

@dynamic code;
@dynamic dateCreated;
@dynamic dateModified;
@dynamic isStillValid;
@dynamic name;
@dynamic symbol;
@dynamic uniqueID;
@dynamic exchangeRateFromCurrency;
@dynamic exchangeRateToCurrency;
@dynamic payment;
@dynamic sharedBill;

@end
