//
//  MCAddCurrenciesEntityMigrationPolicy.m
//  We all pay
//
//  Created by Mark Cornelisse on 22/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCAddCurrenciesEntityMigrationPolicy.h"
#import "MCxRatesController.h"
#import "MCCurrency.h"
#import "MCSharedBill.h"

@implementation MCAddCurrenciesEntityMigrationPolicy

- (BOOL)endInstanceCreationForEntityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error
{
    BOOL returnedFromSuper = [super endInstanceCreationForEntityMapping:mapping manager:manager error:error];
    
    NSManagedObjectContext *destinationContext = [manager destinationContext];
    NSDictionary *availableCurrencies = [MCxRatesController getCurrencyDictionary];
    NSArray *availableCurrencyCodes = [availableCurrencies allKeys];
    for (NSString *currencyCode in availableCurrencyCodes) {
        // For each currencyCode add it.
        MCCurrency *newCurrency = [NSEntityDescription insertNewObjectForEntityForName:@"MCCurrency" inManagedObjectContext:destinationContext];
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
    
    return returnedFromSuper;
}

- (BOOL)endRelationshipCreationForEntityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error
{
    BOOL returnedFromSuper = [super endRelationshipCreationForEntityMapping:mapping manager:manager error:error];
    
    NSManagedObjectContext *destinationContext = [manager destinationContext];
    NSFetchRequest *sharedBillRequest = [NSFetchRequest fetchRequestWithEntityName:@"MCSharedBill"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES];
    [sharedBillRequest setSortDescriptors:@[sortDescriptor]];
    NSError *fetchSharedBillError;
    NSArray *allSharedBills = [destinationContext executeFetchRequest:sharedBillRequest error:&fetchSharedBillError];
    if (!allSharedBills) {
        NSLog(@"Error migrating: %@", [fetchSharedBillError localizedDescription]);
        return NO;
    }
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *currentUsersCurrencyCode = [currentLocale objectForKey:NSLocaleCurrencyCode];
    
    NSFetchRequest *currencyRequest = [NSFetchRequest fetchRequestWithEntityName:@"MCCurrency"];
    NSSortDescriptor *sda = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES];
    [currencyRequest setSortDescriptors:@[sda]];
    NSPredicate *currencyPredicate = [NSPredicate predicateWithFormat:@"code like %@", currentUsersCurrencyCode];
    [currencyRequest setPredicate:currencyPredicate];
    NSError *fetchCurrencyError;
    NSArray *currentUsersCurrency = [destinationContext executeFetchRequest:currencyRequest error:&fetchCurrencyError];
    if (!currentUsersCurrency) {
        NSLog(@"Error migrating: %@", [fetchCurrencyError localizedDescription]);
        return NO;
    }
    MCCurrency *theCurrentCurrency = [currentUsersCurrency firstObject];
    NSLog(@"The current selected Currency is: %@", theCurrentCurrency.code);
    for (MCSharedBill *sharedBill in allSharedBills) {
        [sharedBill setMainCurrency:theCurrentCurrency];
    }
    
    return returnedFromSuper;
}

@end
