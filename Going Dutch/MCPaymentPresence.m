//
//  MCPaymentPresence.m
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCPaymentPresence.h"
#import "MCPayment.h"
#import "MCPerson.h"


@implementation MCPaymentPresence

#pragma mark - NSManagedObject

- (void)awakeFromInsert {
    [super awakeFromInsert];
    [self setPrimitiveValue:NSUUID.UUID.UUIDString forKey:@"uniqueId"];
    NSDate *now = NSDate.date;
    [self setPrimitiveValue:now forKey:@"dateCreated"];
    [self setPrimitiveValue:now forKey:@"dateModified"];
}

#pragma mark - NSObject

@end
