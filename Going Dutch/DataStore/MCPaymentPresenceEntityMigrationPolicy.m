//
//  MCPaymentPresenceEntityMigrationPolicy.m
//  We all pay
//
//  Created by Mark Cornelisse on 26-05-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCPaymentPresenceEntityMigrationPolicy.h"
#import "MCSharedBill+CoreDataProperties.h"
#import "MCPayment+CoreDataProperties.h"
#import "MCCurrency+CoreDataProperties.h"

@implementation MCPaymentPresenceEntityMigrationPolicy

- (BOOL)createRelationshipsForDestinationInstance:(NSManagedObject *)dInstance entityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error
{
    BOOL returnedFromSuper = [super createRelationshipsForDestinationInstance:dInstance entityMapping:mapping manager:manager error:error];
    
    NSManagedObjectContext *context = [dInstance managedObjectContext];
    NSManagedObject *sharedBill = [dInstance valueForKey:@"onWhichBill"];
    NSSet *peoplePresentOnSharedBill = [sharedBill valueForKey:@"peoplePresent"];
    for (NSManagedObject *person in peoplePresentOnSharedBill) {
        NSLog(@"Generating paymentPresence for:%@ %@", [person valueForKey:@"firstName"], [person valueForKey:@"lastName"]);
        NSManagedObject *paymentPresence = [NSEntityDescription insertNewObjectForEntityForName:@"MCPaymentPresence" inManagedObjectContext:context];
        NSDate *dateCreated = [dInstance valueForKey:@"dateCreated"];
        NSDate *dateModified = [dInstance valueForKey:@"dateModified"];
        NSNumber *moneyPaid = [dInstance valueForKey:@"money"];
        NSNumber *moneyOwed = @([moneyPaid doubleValue] / [peoplePresentOnSharedBill count]);
        
        [paymentPresence setValue:dateCreated forKey:@"dateCreated"];
        [paymentPresence setValue:dateModified forKey:@"dateModified"];
        [paymentPresence setValue:@YES forKey:@"isPersonPresent"];
        [paymentPresence setValue:moneyOwed forKey:@"averageOweFromPayment"];
        [paymentPresence setValue:dInstance forKey:@"payment"];
        [paymentPresence setValue:person forKey:@"person"];
        [paymentPresence setValue:[[NSUUID UUID] UUIDString] forKeyPath:@"uniqueId"];
    }
    
    // Fetch current currency from OS.
    NSString *currentCurrencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
    NSFetchRequest *currencyFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MCCurrency"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES];
    [currencyFetchRequest setSortDescriptors:@[sortDescriptor]];
    NSPredicate *currentCurrencyPredicate = [NSPredicate predicateWithFormat:@"code like %@", currentCurrencyCode];
    [currencyFetchRequest setPredicate:currentCurrencyPredicate];
    NSError *currencyFetchError;
    NSArray *currencyFetchResults = [context executeFetchRequest:currencyFetchRequest error:&currencyFetchError];
    if (!currencyFetchResults) {
        NSLog(@"currencyFetchError: %@", currencyFetchError);
        return NO;
    }
    MCCurrency *currentCurrency = currencyFetchResults[0];
    
    // payments to be in current currency.
    MCPayment *thisPayment = (MCPayment *)dInstance;
    [thisPayment setCurrency:currentCurrency];
    thisPayment.categoryId = @(10);
    
    return returnedFromSuper;
}

@end
