//
//  MCReturnPayment.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 11-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import Foundation;

@class MCPerson;
@class MCCurrency;

@interface MCReturnPayment : NSObject
{
    
}

@property (nonatomic, strong) MCPerson *payer;
@property (nonatomic, strong) MCPerson *receiver;
@property (nonatomic, strong) NSNumber *money;

- (id)initWithPayer:(MCPerson *)p paysTo:(MCPerson *)r amountOfMoney:(NSNumber *)m;
- (NSString *)stringForMailIn:(MCCurrency *)currency;

@end
