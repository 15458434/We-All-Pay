//
//  MCPaymentPresence+addons.m
//  We all pay
//
//  Created by Mark Cornelisse on 07-05-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCPaymentPresence+addons.h"
#import "MCPayment+addons.h"
#import "MCSharedBill+addons.h"
#import "MCCurrency+addons.h"
#import "MCExchangeRate+addons.h"

#import "MCWeAllPayStoreController.h"

@implementation MCPaymentPresence (addons)

+ (MCPaymentPresence *)addPaymentPresence
{
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    return [MCPaymentPresence addPaymentPresenceInContext:context];
}

+ (MCPaymentPresence *)addPaymentPresenceInContext:(NSManagedObjectContext *)context
{
    MCPaymentPresence *newPaymentPresence;
    newPaymentPresence = [NSEntityDescription insertNewObjectForEntityForName:@"MCPaymentPresence" inManagedObjectContext:context];
    [newPaymentPresence setUniqueId:[[NSUUID UUID] UUIDString]];
    NSDate *nu = [NSDate date];
    [newPaymentPresence setDateCreated:nu];
    [newPaymentPresence setDateModified:nu];
    return newPaymentPresence;
}

+ (void)deletePaymentPresence:(MCPaymentPresence *)paymentPresence
{
    [[paymentPresence managedObjectContext] deleteObject:paymentPresence];
}

- (NSString *)getCurrencyStringOfAverageOwe
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setLocale:[NSLocale currentLocale]];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    return [nf stringFromNumber:[self averageOweFromPayment]];
}

- (NSNumber *)getAverageOweFromPaymentInMainCurrency
{
    double averageOweFromPaymentDouble = [[self averageOweFromPayment] doubleValue];
    double exchangeRateDouble = 0.0;
    exchangeRateDouble = [[[[self payment] exchangeRate] exchangeRate] doubleValue];
    return @(averageOweFromPaymentDouble * exchangeRateDouble);
}

@end
