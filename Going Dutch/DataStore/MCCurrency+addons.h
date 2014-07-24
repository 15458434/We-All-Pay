//
//  MCCurrency+addons.h
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCCurrency.h"

@interface MCCurrency (addons)

+ (MCCurrency *) getCurrencySelectedInCurrentLocaleFromContext:(NSManagedObjectContext *)context;
+ (void) addAllAvailableCurrenciesToContext:(NSManagedObjectContext *)context;
+ (MCCurrency *) getCurrencyWithCode:(NSString *)code FromContext:(NSManagedObjectContext *)context;

@end
