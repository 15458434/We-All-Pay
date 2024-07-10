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
#import "MCCurrency+addons.h"

@implementation MCSharedBill

#pragma mark - NSManagedObject

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    [self setPrimitiveValue:NSUUID.UUID.UUIDString forKey:@"uniqueBillId"];
    [self setPrimitiveValue:@NO forKey:@"hasTheMailBeenSent"];
    NSDate *now = NSDate.date;
    [self setPrimitiveValue:now forKey:@"dateCreated"];
    [self setPrimitiveValue:now forKey:@"dateModified"];
    MCCurrency *mainCurrency = [MCCurrency generateCurrencyFromSelectedLocaleForContext:self.managedObjectContext];
    [self setPrimitiveValue:mainCurrency forKey:@"mainCurrency"];
}

#pragma mark - NSObject

@end
