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

// - (NSArray *)fetchAllPayments;

- (NSString *)stringOfApproxPeoplePresent;

- (BOOL)areTherePeople;
- (NSUInteger)totalAmountOfPeoplePresent;
- (NSUInteger)totalAmountOfPeopleWhoHavePaid;

- (NSArray *)solveWhoHasToPayWhoFromThisBill;
- (NSNumber *)totalSumOfMoneyOfThisSharedBill;
- (NSNumber *)totalSumPaidBy:(MCPerson *)person;
- (NSNumber *)amountPeopleShouldHavePaid;
- (BOOL)hasPersonPaidSomething:(MCPerson *)person;
- (BOOL)doesEveryoneHaveAnEmailAddress;

@end
