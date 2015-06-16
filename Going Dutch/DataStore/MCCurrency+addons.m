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

#import "We_all_pay-Swift.h"

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
    NSString *currencyCodeFromCurrentLocale = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
    // currencyCode from Current locale is necessary. Set the current locale for the simulator.
    NSParameterAssert(currencyCodeFromCurrentLocale);
    NSString *currencyNameFromCurrentLocale = [[[MCWeAllPayStoreController defaultStore] fetcher] currencyController][currencyCodeFromCurrentLocale];
    NSString *currencySymbolFromCurrentLocale = [[[[MCWeAllPayStoreController defaultStore] fetcher] currencyController] currencySymbol:currencyCodeFromCurrentLocale];
    MCCurrency *newCurrency = [NSEntityDescription insertNewObjectForEntityForName:@"MCCurrency" inManagedObjectContext:context];
    newCurrency.code = currencyCodeFromCurrentLocale;
    newCurrency.name = currencyNameFromCurrentLocale;
    newCurrency.symbol = currencySymbolFromCurrentLocale;
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

+ (MCCurrency *)currencyFrom:(NSString *)code fromContext:(NSManagedObjectContext *)context
{
    CurrencyController *currencyController = [[[MCWeAllPayStoreController defaultStore] fetcher] currencyController];
    MCCurrency *newCurrency = [NSEntityDescription insertNewObjectForEntityForName:@"MCCurrency" inManagedObjectContext:context];
    NSDate *now = [NSDate date];
    newCurrency.dateCreated = now;
    newCurrency.dateModified = now;
    newCurrency.uniqueID = [[NSUUID UUID] UUIDString];
    newCurrency.name = currencyController[code];
    newCurrency.symbol = [currencyController currencySymbol:code];
    newCurrency.code = code;
    newCurrency.isStillValid = @YES;
    return newCurrency;
}

+ (void)addAllAvailableCurrenciesToContext:(NSManagedObjectContext *)context
{
    // TODO: Why is this only used for testing?
    NSArray *currencies = [[[[MCWeAllPayStoreController defaultStore] fetcher] currencyController] currencies];
    for (NSDictionary *currency in currencies) {
        // For each currencyCode add it.
        MCCurrency *newCurrency = [NSEntityDescription insertNewObjectForEntityForName:@"MCCurrency" inManagedObjectContext:context];
        NSDate *now = [NSDate date];
        newCurrency.uniqueID = [[NSUUID UUID] UUIDString];
        newCurrency.dateCreated = now;
        newCurrency.dateModified = now;
        newCurrency.isStillValid = @YES;
        newCurrency.name = currency[@"name"];
        newCurrency.code = currency[@"code"];
        newCurrency.symbol = [[[[MCWeAllPayStoreController defaultStore] fetcher] currencyController] currencySymbol:currency[@"code"]];
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

#pragma mark - Inherited from super

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self setPrimitiveValue:[[NSUUID UUID] UUIDString] forKey:@"uniqueID"];
    NSDate *now = [NSDate date];
    [self setPrimitiveValue:now forKey:@"dateCreated"];
    [self setPrimitiveValue:now forKey:@"dateModified"];
}

@end
