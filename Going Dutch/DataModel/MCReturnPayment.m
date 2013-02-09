//
//  MCReturnPayment.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 11-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCReturnPayment.h"
#import "MCPerson.h"

@implementation MCReturnPayment

@synthesize payer;
@synthesize receiver;
@synthesize money;

- (id)initWithPayer:(MCPerson *)p paysTo:(MCPerson *)r amountOfMoney:(double)m
{
    self = [super init];
    
    if (self) {
        payer = p;
        receiver = r;
        money = m;
    }
    
    return self;
}

- (NSString *)description
{
    NSNumber *m = [[NSNumber alloc] initWithDouble:money];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    return [[NSString alloc] initWithFormat:@"%@ has to pay %@ to %@.", [payer name], [nf stringFromNumber:m], [receiver name]];
}

@end
