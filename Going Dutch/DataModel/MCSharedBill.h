//
//  MCSharedBill.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCPayment.h"

@class MCPeople;

@interface MCSharedBill : MCPayment <NSCoding>
{
    NSString *uniqueBillId;
    NSMutableArray *payments;
    MCPeople *people;
}

- (id)initWithTestGroup;
- (NSArray *)allPayments;
- (BOOL)areTherePeople;
- (void)addPayment:(MCPayment *)newPayment;
- (void)removePayment:(MCPayment *)removePayment;
- (void)removePerson:(MCPerson *)awfulPerson;
- (NSArray *)solveWhoHasToPayWhoFromThisBill;
- (double)totalSumOfMoneyOfThisSharedBill;
- (double)totalSumPaidBy:(MCPerson *)person;
- (double)amountPeopleShouldHavePaid;
- (BOOL)hasPersonPaidSomething:(MCPerson *)person;

@property (nonatomic, strong) NSString *uniqueBillId;
@property (nonatomic, strong) NSString *tripName;
@property (nonatomic, strong) MCPeople *people;

@end
