//
//  MCSharedBill.m
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBill.h"
#import "MCCurrency.h"
#import "MCPayment.h"
#import "MCPerson.h"
#import "MCCurrency+CoreDataProperties.h"
#import "CurrencyConverter/CurrencyConverter.h"

#import "We_all_pay-Swift.h"

@implementation MCSharedBill

#pragma mark - NSManagedObject

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    [self setPrimitiveValue:NSUUID.UUID.UUIDString forKey:@"uniqueBillId"];
    [self setPrimitiveValue:@NO forKey:@"hasTheMailBeenSent"];
    NSDate *now = NSDate.date;
    [self setPrimitiveValue:now forKey:@"dateCreated"];
    [self setPrimitiveValue:now forKey:@"dateModified"];
    MCCurrencyModel *currencyModel = [[MCCurrencyModel alloc] initWithManagedObjectContext:self.managedObjectContext andWithCurrencyController:[[CurrencyController alloc] init]];
    NSError *error;
    MCCurrency *mainCurrency = [currencyModel generateCurrencyFromSelectedLocaleWithError:&error];
    NSParameterAssert(error == nil);
    [self setPrimitiveValue:mainCurrency forKey:@"mainCurrency"];
}

#pragma mark - NSObject

@end
