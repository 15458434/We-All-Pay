//
//  MCSharedBill.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBill.h"
#import "MCPeople.h"

@implementation MCSharedBill

@synthesize tripName;
@synthesize people;
@synthesize uniqueBillId;

- (NSArray *)solveWhoHasToPayWhoFromThisBill
{
    NSMutableArray *solveArray = [[NSMutableArray alloc] init];
    for (MCPerson *p in [people allPeople]) {
        double sumOfWhatPPaid = [self totalSumPaidBy:p];
        NSNumber *sOWPP = [[NSNumber alloc] initWithDouble:sumOfWhatPPaid];
        NSArray *totalAmountSomeonePaid = [[NSArray alloc] initWithObjects:p, sOWPP, nil];
        [solveArray addObject:totalAmountSomeonePaid];
    }
    // Nu is er een array met wie wat betaald heeft.
    return nil;
}

- (double)totalSumOfMoneyOfThisSharedBill
{
    double total = 0.0;
    for (MCPayment *p in payments) {
        total += [p money];
    }
    return total;
}

- (double)totalSumPaidBy:(MCPerson *)person
{
    double total = 0.0;
    for (MCPayment *p in payments) {
        if (person == [p payingPerson]) {
            total += [p money];
        }
    }
    return total;
}

- (double)amountPeopleShouldHavePaid
{
    NSNumber *amountOfPeople = [[NSNumber alloc] initWithInteger:[[people allPeople] count]];
    return [self totalSumOfMoneyOfThisSharedBill] / [amountOfPeople doubleValue];
}

- (id)initWithTestGroup
{
    self = [super init];
    
    if (self) {
        payments = [[NSMutableArray alloc] init];
        people = [MCPeople createTestGroup];
        tripName = [[NSString alloc] initWithFormat:@"Test friday"];
    }
    return self;
}

- (NSArray *)allPayments
{
    return payments;
}

- (MCPeople *)allPeople
{
    return people;
}

- (BOOL)areTherePeople
{
    return [people areTherePeople];
}

- (void)removePerson:(MCPerson *)awfulPerson
{
    [people removePerson:awfulPerson];
}

- (void)addPayment:(MCPayment *)newPayment
{
    [payments addObject:newPayment];
}

- (void)removePayment:(MCPayment *)removePayment
{
    [payments removeObject:removePayment];
}

- (BOOL)hasPersonPaidSomething:(MCPerson *)person
{
    for (MCPayment *iPayment in payments) {
        if (person == [iPayment payingPerson]) {
            return YES;
        }
    }
    return NO;
}

- (double)money
{
    if ([payments count] == 0) {
        return [super money];
    } else {
        double totalmoney = 0.0;
        for (MCPayment *everypayment in payments) {
            totalmoney += [everypayment money];
        }
        return totalmoney;
    }
}

- (id)init
{
    self = [super init];
    
    if (self) {
        payments = [[NSMutableArray alloc] init];
        people = [[MCPeople alloc] init];
        tripName = [[NSString alloc] initWithFormat:@""];
    }
    
    return self;
}

- (NSString *)description
{

    NSNumberFormatter *numberformatter = [[NSNumberFormatter alloc] init];
    [numberformatter setLocale:[NSLocale currentLocale]];
    [numberformatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    return [[NSString alloc] initWithFormat:@"%@ cost %@", tripName ,[numberformatter stringFromNumber:[[NSNumber alloc] initWithDouble:[self money]]]];
}

@end
