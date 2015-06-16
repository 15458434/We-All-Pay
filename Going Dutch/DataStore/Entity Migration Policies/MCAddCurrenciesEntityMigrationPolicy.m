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
#import "MCExchangeRate.h"
#import "MCPayment.h"

#import "We_all_pay-Swift.h"

@implementation MCAddCurrenciesEntityMigrationPolicy

- (BOOL)endInstanceCreationForEntityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error
{
    // TODO: Test all migrations.
    BOOL returnedFromSuper = [super endInstanceCreationForEntityMapping:mapping manager:manager error:error];
    
    NSManagedObjectContext *destinationContext = [manager destinationContext];
    CurrencyController *currencyController = [[CurrencyController alloc] init];
    NSString *currencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
    MCCurrency *newCurrency = [NSEntityDescription insertNewObjectForEntityForName:@"MCCurrency" inManagedObjectContext:destinationContext];
    NSString *uuidString = [[NSUUID UUID] UUIDString];
    NSDate *now = [NSDate date];
    NSString *currencyName = currencyController[currencyCode];
    NSString *currencySymbol = [[NSLocale systemLocale] displayNameForKey:NSLocaleCurrencySymbol value:currencyCode];
    newCurrency.uniqueID = uuidString;
    newCurrency.dateCreated = now;
    newCurrency.dateModified = now;
    newCurrency.isStillValid = @YES;
    newCurrency.name = currencyName;
    newCurrency.code = currencyCode;
    newCurrency.symbol = currencySymbol;
    NSLog(@"Generated MCCurrency: %@", newCurrency);
    
    return returnedFromSuper;
}

- (BOOL)endRelationshipCreationForEntityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error
{
    BOOL returnedFromSuper = [super endRelationshipCreationForEntityMapping:mapping manager:manager error:error];
    
    NSManagedObjectContext *destinationContext = [manager destinationContext];
    NSFetchRequest *sharedBillRequest = [NSFetchRequest fetchRequestWithEntityName:@"MCSharedBill"];
    sharedBillRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    NSError *fetchSharedBillError;
    NSArray *allSharedBills = [destinationContext executeFetchRequest:sharedBillRequest error:&fetchSharedBillError];
    if (!allSharedBills) {
        NSLog(@"Error migrating: %@", [fetchSharedBillError localizedDescription]);
        return NO;
    }
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *currentUsersCurrencyCode = [currentLocale objectForKey:NSLocaleCurrencyCode];
    
    NSFetchRequest *currencyRequest = [NSFetchRequest fetchRequestWithEntityName:@"MCCurrency"];
    currencyRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    currencyRequest.predicate = [NSPredicate predicateWithFormat:@"code like %@", currentUsersCurrencyCode];
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
        for (MCPayment *payment in [sharedBill payments]) {
            // Create exchangeRate objects for each payment
            if (![payment currency]) {
                [payment setCurrency:theCurrentCurrency];
            }
            MCExchangeRate *exchangeRate = [NSEntityDescription insertNewObjectForEntityForName:@"MCExchangeRate" inManagedObjectContext:destinationContext];
            exchangeRate.uniqueID = [[NSUUID UUID] UUIDString];
            NSDate *now = [NSDate date];
            exchangeRate.dateCreated = payment.dateCreated;
            exchangeRate.dateModified = now;
            exchangeRate.dateFetched = payment.dateModified;
            exchangeRate.exchangeRate = @1.00;
            exchangeRate.toCurrency = payment.onWhichBill.mainCurrency;
            exchangeRate.fromCurrency = payment.currency;
            exchangeRate.source = @"WeAllPayStore Migration 2";
            exchangeRate.payment = payment;
            NSLog(@"Payment %@ got exchangeRate %@",payment, exchangeRate);
        }
    }
    
    return returnedFromSuper;
}

@end
