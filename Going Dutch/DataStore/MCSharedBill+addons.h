//
//  MCSharedBill+addons.h
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBill.h"
#import "MCPerson+addons.h"

@interface MCSharedBill (addons)

+ (MCSharedBill *)addSharedBill;
+ (void)deleteSharedbill:(MCSharedBill *)deleteBill;

+ (MCSharedBill *)fetchSharedBillWithUniqueId:(NSString *)uuid;
+ (BOOL)isTableInDatabaseEmpty;

- (NSString *)stringOfApproxPeoplePresent;
- (NSString *)stringOfApproxPeoplePresentWithFullNames;

- (MCPayment *)addPayment;

- (MCPerson *)addPerson;
- (BOOL)isPresentWithFirstName:(NSString *)firstName andLastName:(NSString *)lastName andEmailAddress:(NSString *)emailAddress;
- (BOOL)areTherePeople;
- (NSUInteger)totalAmountOfPeoplePresent;
- (NSUInteger)totalAmountOfPeopleWhoHavePaid;

- (NSArray *)solveWhoHasToPayWhoFromThisBill;
- (NSNumber *)totalSumOfMoneyOfThisSharedBill;
- (NSString *)totalSumOfMoneyOfThisSharedBillAsCurrencyString;
- (NSNumber *)totalSumPaidBy:(MCPerson *)person;
- (NSNumber *)totalAmountOfCreditBy:(MCPerson *)person;
- (NSNumber *)amountPeopleShouldHavePaid;
- (NSString *)amountPeopleShouldHavePaidAsCurrencyString;
- (BOOL)hasPersonPaidSomething:(MCPerson *)person;
- (BOOL)doesEveryoneHaveAnEmailAddress;

- (NSArray *)getArrayOfFullNamesOfPeoplePresent;

@end
