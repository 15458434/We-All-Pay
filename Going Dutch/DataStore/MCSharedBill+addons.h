//
//  MCSharedBill+addons.h
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBill.h"

@interface MCSharedBill (addons)

+ (MCSharedBill *)addSharedBill;
+ (void)deleteSharedbill:(MCSharedBill *)deleteBill;

+ (MCSharedBill *)fetchSharedBillWithUniqueId:(NSString *)uuid;

- (NSArray *)fetchAllPayments;

- (NSString *)stringOfApproxPeoplePresent;

- (BOOL)areTherePeople;
- (NSUInteger)totalAmountOfPeoplePresent;
- (NSUInteger)totalAmountOfPeopleWhoHavePaid;

- (BOOL)addPerson:(MCPerson *)newPerson;
- (void)removePerson:(MCPerson *)awfulPerson;

- (void)addPayment:(MCPayment *)newPayment;
- (void)removePayment:(MCPayment *)removePayment;

- (NSArray *)solveWhoHasToPayWhoFromThisBill;
- (double)totalSumOfMoneyOfThisSharedBill;
- (NSNumber *)totalSumPaidBy:(MCPerson *)person;
- (double)amountPeopleShouldHavePaid;
- (BOOL)hasPersonPaidSomething:(MCPerson *)person;
- (NSArray *)whatHasPersonPaid:(MCPerson *)person;

@end
