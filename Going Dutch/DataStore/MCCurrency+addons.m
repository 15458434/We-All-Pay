//
//  MCCurrency+addons.m
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCCurrency+addons.h"
#import "MCWeAllPayStoreController.h"

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

- (BOOL)isEqualToMCCurrency:(MCCurrency *)object {
    return [self.code isEqualToString:object.code];
}

#pragma mark - NSManagedObject

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self setPrimitiveValue:[[NSUUID UUID] UUIDString] forKey:@"uniqueID"];
    NSDate *now = [NSDate date];
    [self setPrimitiveValue:now forKey:@"dateCreated"];
    [self setPrimitiveValue:now forKey:@"dateModified"];
}

#pragma mark - NSObject

@end
