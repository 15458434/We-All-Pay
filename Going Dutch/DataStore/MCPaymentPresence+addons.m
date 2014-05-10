//
//  MCPaymentPresence+addons.m
//  We all pay
//
//  Created by Mark Cornelisse on 07-05-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCPaymentPresence+addons.h"

#import "MCWeAllPayStoreController.h"

@implementation MCPaymentPresence (addons)

+ (MCPaymentPresence *)addPaymentPresence
{
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    MCPaymentPresence *newPaymentPresence;
    newPaymentPresence = [NSEntityDescription insertNewObjectForEntityForName:@"MCPaymentPresence" inManagedObjectContext:context];
    [newPaymentPresence setUniqueId:[[NSUUID UUID] UUIDString]];
    return newPaymentPresence;
}

+ (void)deletePaymentPresence:(MCPaymentPresence *)paymentPresence
{
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context deleteObject:paymentPresence];
}

@end
