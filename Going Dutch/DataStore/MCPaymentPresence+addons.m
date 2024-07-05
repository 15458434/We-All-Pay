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

#import "We_all_pay-Swift.h"

@implementation MCPaymentPresence (addons)

+ (MCPaymentPresence *)addPaymentPresence
{
    NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] viewContext];
    return [MCPaymentPresence addPaymentPresenceInContext:context];
}

+ (MCPaymentPresence *)addPaymentPresenceInContext:(NSManagedObjectContext *)context
{
    MCPaymentPresence *newPaymentPresence = [NSEntityDescription insertNewObjectForEntityForName:@"MCPaymentPresence" inManagedObjectContext:context];
    newPaymentPresence.uniqueId = [[NSUUID UUID] UUIDString];
    NSDate *now = [NSDate date];
    newPaymentPresence.dateCreated = now;
    newPaymentPresence.dateModified = now;
    return newPaymentPresence;
}

+ (void)deletePaymentPresence:(MCPaymentPresence *)paymentPresence
{
    [[paymentPresence managedObjectContext] deleteObject:paymentPresence];
}

- (NSNumber *)getAverageOweFromPaymentInMainCurrency
{
    double averageOweFromPaymentDouble = [[self averageOweFromPayment] doubleValue];
    double exchangeRateDouble = 0.0;
    exchangeRateDouble = [[[[self payment] exchangeRate] exchangeRate] doubleValue];
    return @(averageOweFromPaymentDouble * exchangeRateDouble);
}

@end
