//
//  MCCurrency+addons.m
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCCurrency+addons.h"
#import "MCWeAllPayStoreController.h"
#import "MCxRatesController.h"

@implementation MCCurrency (addons)

+ (MCCurrency *)getCurrencySelectedInCurrentLocaleFromContext:(NSManagedObjectContext *)context
{
    NSParameterAssert(context);
    NSString *currentCurrencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
    return [MCCurrency getCurrencyWithCode:currentCurrencyCode FromContext:context];
}

+ (void)addAllAvailableCurrenciesToContext:(NSManagedObjectContext *)context
{
    NSDictionary *availableCurrencies = [MCxRatesController getCurrencyDictionary];
    NSArray *availableCurrencyCodes = [availableCurrencies allKeys];
    for (NSString *currencyCode in availableCurrencyCodes) {
        // For each currencyCode add it.
        MCCurrency *newCurrency = [NSEntityDescription insertNewObjectForEntityForName:@"MCCurrency" inManagedObjectContext:context];
        NSString *uuidString = [[NSUUID UUID] UUIDString];
        NSDate *now = [NSDate date];
        NSString *currencyName = [[availableCurrencies objectForKey:currencyCode] objectForKey:@"name"];
        NSString *currencySymbol = [MCxRatesController getSymbolForCurrencyISOCode:currencyCode];
        [newCurrency setUniqueID:uuidString];
        [newCurrency setDateCreated:now];
        [newCurrency setDateModified:now];
        [newCurrency setIsStillValid:@YES];
        [newCurrency setName:currencyName];
        [newCurrency setCode:currencyCode];
        [newCurrency setSymbol:currencySymbol];
        NSLog(@"Generated MCCurrency: %@", newCurrency);
    }
}

+ (MCCurrency *)getCurrencyWithCode:(NSString *)code FromContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCCurrency"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code like %@", code];
    [request setPredicate:predicate];
    NSError *fetchError;
    NSArray *fetchResults = [context executeFetchRequest:request error:&fetchError];
    if (!fetchResults) {
        NSLog(@"Fetching currencySelectedInCurrentLocale did fail: %@", [fetchError localizedDescription]);
    }
    return [fetchResults firstObject];
}

- (NSNumberFormatter *)numberFormatter
{
    NSNumberFormatter *newNumberFormatter = [NSNumberFormatter new];
    [newNumberFormatter setLocale:[NSLocale currentLocale]];
    [newNumberFormatter setCurrencyCode:[self code]];
    [newNumberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [newNumberFormatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    return newNumberFormatter;
}

@end
