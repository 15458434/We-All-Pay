//
//  MCReturnPayment.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 11-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCReturnPayment.h"
#import "MCPerson.h"
#import "MCCurrency+addons.h"

#import "We_all_pay-Swift.h"

@implementation MCReturnPayment

- (id)initWithPayer:(MCPerson *)p paysTo:(MCPerson *)r amountOfMoney:(NSNumber *)m
{
    self = [super init];
    
    if (self) {
        _payer = p;
        _receiver = r;
       _money = m;
    }
    
    return self;
}

- (NSString *)stringForMailIn:(MCCurrency *)currency
{
    CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:currency.code];
    
    NSString *owesString1 = NSLocalizedString(@"EMAIL_OWES_PART_ONE", @"Part one of the words: %@ pays %@ to %@.");
    NSString *owesString2 = NSLocalizedString(@"EMAIL_OWES_PART_TWO", @"Part two of the words: %@ pays %@ to %@.");
    return [[NSString alloc] initWithFormat:@"%@ %@ %@ %@ %@.", [_payer firstName], owesString1, [cf stringForObjectValue:_money], owesString2, [_receiver firstName]];
}

- (NSString *)description
{
    CurrencyFormatter *cf = [[CurrencyFormatter alloc] init];
    
    return [[NSString alloc] initWithFormat:@"%@ owes %@ to %@.", [_payer firstName], [cf stringForObjectValue:_money], [_receiver firstName]];
}

@end
