//
//  MCPaymentUpdateTo4.m
//  We all pay
//
//  Created by Mark Cornelisse on 18/11/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCPaymentUpdateTo4.h"
#import "MCPayment+CoreDataProperties.h"

@implementation MCPaymentUpdateTo4

- (BOOL)createRelationshipsForDestinationInstance:(NSManagedObject *)dInstance entityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error
{
    MCPayment *paymentInDestinationInstance = (MCPayment *)dInstance;
    paymentInDestinationInstance.categoryId = @(10);
#ifdef DEBUG
    NSLog(@"%@", paymentInDestinationInstance);
#endif
    return YES;
}

@end
