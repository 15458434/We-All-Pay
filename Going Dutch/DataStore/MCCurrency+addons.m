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

#import "XRCurrencyStoreController.h"
#import "XRCurrency.h"

@implementation MCCurrency (addons)

+ (MCCurrency *)getCurrencySelectedInCurrentLocaleFromContext:(NSManagedObjectContext *)context
{
    // Still present for downwards compatibility.
    return [MCCurrency generateCurrencyFromSelectedLocaleForContext:context];
}

+ (MCCurrency *)generateCurrencyFromSelectedLocaleForContext:(NSManagedObjectContext *)context;
{
#if DEBUG
    NSLog(@"%@ generateCurrencyFromSelectedLocaleForContext", self);
#endif
    NSParameterAssert(context);
//    NSDictionary *allCurrenciesDictionary = [MCxRatesController getCurrencyDictionary];
    NSString *currencyCodeFromCurrentLocale = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
//    NSDictionary *currencyDictionaryFromCurrencyCode = [allCurrenciesDictionary objectForKey:currencyCodeFromCurrentLocale];
    NSManagedObjectContext *xrContext = [[XRCurrencyStoreController sharedStore] mainQueueContext];
    XRCurrency *xrCurrency = [[XRCurrencyStoreController sharedStore] fetchCurrencyWithCode:currencyCodeFromCurrentLocale inContext:xrContext];
    MCCurrency *newCurrency = [NSEntityDescription insertNewObjectForEntityForName:@"MCCurrency" inManagedObjectContext:context];
    newCurrency.code = [xrCurrency.code copy];
    newCurrency.name = [xrCurrency.name copy];
    newCurrency.symbol = [xrCurrency.symbol copy];
    newCurrency.isStillValid = @YES;
    return newCurrency;
}

+ (MCCurrency *)getCurrencyFrom:(XRCurrency *)xrCurrency FromContext:(NSManagedObjectContext *)context
{
    MCCurrency *newCurrency = [NSEntityDescription insertNewObjectForEntityForName:@"MCCurrency" inManagedObjectContext:context];
    NSDate *now = [NSDate date];
    newCurrency.dateCreated = now;
    newCurrency.dateModified = now;
    newCurrency.uniqueID = [[NSUUID UUID] UUIDString];
    newCurrency.name = xrCurrency.name;
    newCurrency.symbol = xrCurrency.symbol;
    newCurrency.code = xrCurrency.code;
    newCurrency.isStillValid = xrCurrency.isStillValid;
    return newCurrency;
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
    NSManagedObjectContext *xrMainQueueContext = [[XRCurrencyStoreController sharedStore] mainQueueContext];
    XRCurrency *xrCurrency = [[XRCurrencyStoreController sharedStore] fetchCurrencyWithCode:code inContext:xrMainQueueContext];
    MCCurrency *mcCurrency = [NSEntityDescription insertNewObjectForEntityForName:@"MCCurrency" inManagedObjectContext:context];
    NSDate *now = [NSDate date];
    mcCurrency.dateCreated = now;
    mcCurrency.dateModified = now;
    mcCurrency.uniqueID = [[NSUUID UUID] UUIDString];
    mcCurrency.name = xrCurrency.name;
    mcCurrency.symbol = xrCurrency.symbol;
    mcCurrency.code = xrCurrency.code;
    mcCurrency.isStillValid = xrCurrency.isStillValid;
    return mcCurrency;
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCCurrency"];
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES];
//    [request setSortDescriptors:@[sortDescriptor]];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code like %@", code];
//    [request setPredicate:predicate];
//    NSError *fetchError;
//    NSArray *fetchResults = [context executeFetchRequest:request error:&fetchError];
//    if (!fetchResults) {
//        NSLog(@"Fetching currencySelectedInCurrentLocale did fail: %@", [fetchError localizedDescription]);
//    }
//    return [fetchResults firstObject];
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
