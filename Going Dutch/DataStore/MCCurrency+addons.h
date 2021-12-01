//
//  MCCurrency+addons.h
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCCurrency+CoreDataProperties.h"

@class XRCurrency;

@interface MCCurrency (addons)

+ (MCCurrency *)generateCurrencyFromSelectedLocaleForContext:(NSManagedObjectContext *)context;
+ (void) addAllAvailableCurrenciesToContext:(NSManagedObjectContext *)context;

- (BOOL)isEqualToMCCurrency:(MCCurrency *)object;

+ (MCCurrency *)currencyFrom:(NSString *)code fromContext:(NSManagedObjectContext *)context;

@end
