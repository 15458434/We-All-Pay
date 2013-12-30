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

- (id)initWithPayer:(MCPerson *)p paysTo:(MCPerson *)r amountOfMoney:(NSNumber *)m
{
    self = [super init];
    
    if (self) {
        payer = p;
        receiver = r;
        money = m;
    }
    
    return self;
}

- (NSString *)stringForMail
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSString *owesString1 = NSLocalizedString(@"EMAIL_OWES_PART_ONE", @"Part one of the words: %@ pays %@ to %@.");
    NSString *owesString2 = NSLocalizedString(@"EMAIL_OWES_PART_TWO", @"Part two of the words: %@ pays %@ to %@.");
    return [[NSString alloc] initWithFormat:@"%@ %@ %@ %@ %@.", [payer firstName], owesString1, [nf stringFromNumber:money], owesString2, [receiver firstName]];
}

- (NSString *)description
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    return [[NSString alloc] initWithFormat:@"%@ owes %@ to %@.", [payer firstName], [nf stringFromNumber:money], [receiver firstName]];
}

@end
