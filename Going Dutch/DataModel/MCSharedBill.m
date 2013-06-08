//
//  MCSharedBill.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBill.h"
#import "MCPeople.h"
#import "MCReturnPayment.h"
#import "MCPerson.h"
#import "MCTools.h"

@implementation MCSharedBill

@synthesize tripName;
@synthesize people;
@synthesize uniqueBillId;
@synthesize dateCreated;
@synthesize dateModified;

#pragma mark - New in this class

- (NSArray *)solveWhoHasToPayWhoFromThisBill
{
    // Create two array's one of peope who should pay and one with people that should receive.
    NSMutableArray *payers = [[NSMutableArray alloc] init];
    NSNumber *leftToPay;
    NSNumber *leftToReceive;
    NSMutableArray *receivers = [[NSMutableArray alloc] init];
    NSMutableArray *whoHasToPayWho = [[NSMutableArray alloc] init];
    for (MCPerson *p in [people allPeople]) {
        NSNumber *sumOfWhatWasPaidBy = [[NSNumber alloc] initWithDouble:[self totalSumPaidBy:p]];
        NSNumber *sumOfWhatShouldBePaid = [[NSNumber alloc] initWithDouble:[self amountPeopleShouldHavePaid]];

        if ([sumOfWhatWasPaidBy doubleValue] < [sumOfWhatShouldBePaid doubleValue]) {
            // This person should pay to someone.
            leftToPay = [[NSNumber alloc] initWithDouble:[sumOfWhatShouldBePaid doubleValue] - [sumOfWhatWasPaidBy doubleValue]];
            NSArray *creditValueOfThisPerson = [[NSMutableArray alloc] initWithObjects:p, sumOfWhatShouldBePaid, sumOfWhatWasPaidBy, leftToPay, nil];
            [payers addObject:creditValueOfThisPerson];
        } else if ([sumOfWhatWasPaidBy doubleValue] > [sumOfWhatShouldBePaid doubleValue]){
            // This person should receive from someone.
            leftToReceive = [[NSNumber alloc] initWithDouble:[sumOfWhatWasPaidBy doubleValue] - [sumOfWhatShouldBePaid doubleValue]];
            NSArray *creditValueOfThisPerson = [[NSMutableArray alloc] initWithObjects:p, sumOfWhatShouldBePaid, sumOfWhatWasPaidBy, leftToReceive, nil];
            [receivers addObject:creditValueOfThisPerson];
        } else {
            // This person has already paid enough.
            MCReturnPayment *notDepted = [[MCReturnPayment alloc] initWithPayer:p paysTo:nil amountOfMoney:0.0];
            [whoHasToPayWho addObject:notDepted];
        }
    }
    
    // Solve who has to pay who.
    for (NSMutableArray *p in payers) {
        for (NSMutableArray *r in receivers) {
            double ltp = [[p objectAtIndex:3] doubleValue];
            double ltr = [[r objectAtIndex:3] doubleValue];
            MCReturnPayment *rp;
            if (ltp >= ltr) {
                rp = [[MCReturnPayment alloc] initWithPayer:[p objectAtIndex:0] paysTo:[r objectAtIndex:0] amountOfMoney:ltr];
                ltp -= ltr;
                ltr = 0;
            } else {
                rp = [[MCReturnPayment alloc] initWithPayer:[p objectAtIndex:0] paysTo:[r objectAtIndex:0] amountOfMoney:ltp];
                ltr -= ltp;
                ltp = 0;
            }
            leftToPay = [[NSNumber alloc] initWithDouble:ltp];
            leftToReceive = [[NSNumber alloc] initWithDouble:ltr];
            [p replaceObjectAtIndex:3 withObject:leftToPay];
            [r replaceObjectAtIndex:3 withObject:leftToReceive];
            
            if ([rp money] > 0) {
                [whoHasToPayWho addObject:rp];
            }
        }
    }
    return whoHasToPayWho;
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
    [payments insertObject:newPayment atIndex:0];
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

- (NSUInteger)totalAmountOfPeople
{
    return [[people allPeople] count];
}

#pragma mark - Inherited From super.

- (id)init
{
    self = [super init];
    
    if (self) {
        uniqueBillId = [MCTools createUniqueIdentifierString];
        payments = [[NSMutableArray alloc] init];
        people = [[MCPeople alloc] init];
        tripName = [[NSString alloc] initWithFormat:@""];
        dateCreated = [[NSDate alloc] init];
        dateModified = [dateCreated copy];
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

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:uniqueBillId forKey:@"uniqueBillId"];
    [aCoder encodeObject:payments forKey:@"payments"];
    [aCoder encodeObject:people forKey:@"people"];
    [aCoder encodeObject:tripName forKey:@"tripName"];
    [aCoder encodeObject:dateCreated forKey:@"dateCreated"];
    [aCoder encodeObject:dateModified forKey:@"dateModified"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        uniqueBillId = [aDecoder decodeObjectForKey:@"uniqueBillId"];
        payments = [aDecoder decodeObjectForKey:@"payments"];
        people = [aDecoder decodeObjectForKey:@"people"];
        tripName = [aDecoder decodeObjectForKey:@"tripName"];
        dateCreated = [aDecoder decodeObjectForKey:@"dateCreated"];
        if (!dateCreated) {
            dateCreated = [[NSDate alloc] init];
        }
        dateModified = [aDecoder decodeObjectForKey:@"dateModified"];
        if (!dateModified) {
            dateModified = [[NSDate alloc] init];
        }
    }
    return self;
}

@end
