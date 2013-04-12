//
//  MCSharedPayment.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPayment.h"
#import "MCReturnPayment.h"
#import "MCPeople.h"
#import "MCPerson.h"
#import "MCTools.h"

@implementation MCPayment

@synthesize uniquePaymentID;
@synthesize money;
@synthesize payingPerson;
@synthesize place;
@synthesize timePaid;

#pragma mark - New in this class

- (double)amountPeopleShouldHavePaid:(NSArray *)peoplePresent
{
    return money / [peoplePresent count];
}

+(MCPayment *)createRandomPayment
{
    // Create Arrays of persons and places;
    NSArray *persons = [[NSArray alloc] initWithObjects:@"Iva", @"Merit", @"Marieke", @"Lieke", @"Monia", nil];
    NSArray *places = [[NSArray alloc] initWithObjects:@"Sauna", @"Foute kroeg", @"Film Theater", @"Tapas Bar", nil];
    NSInteger randomPerson = rand() % [persons count];
    NSInteger randomPlace = rand() % [places count];
    NSNumber *randomMoney = [[NSNumber alloc] initWithInteger:rand() % 100];
    
    // Create randomPayment object and fill it with random generated data.
    MCPayment *randomPayment = [[MCPayment alloc] initWithPerson:[persons objectAtIndex:randomPerson]
                                                                       place:[places objectAtIndex:randomPlace]
                                                                       money:[randomMoney floatValue]];
    
    return randomPayment;
}

+ (MCPayment *)createRandomPaymentWithGroup:(MCPeople *)p
{
    if ([[p allPeople] count] != 0) {
        NSInteger pn = rand() % [[p allPeople] count];
        MCPerson *selectedPerson = [[p allPeople] objectAtIndex:pn];
        NSNumber *randomMoney = [[NSNumber alloc] initWithInteger:rand() % 100];
    
        NSArray *places = [[NSArray alloc] initWithObjects:@"Sauna", @"Foute kroeg", @"Film Theater", @"Tapas Bar", nil];
        NSInteger randomPlace = rand() % [places count];
    
        MCPayment *randomPayment = [[MCPayment alloc] initWithPerson:selectedPerson
                                                               place:[places objectAtIndex:randomPlace]
                                                               money:[randomMoney doubleValue]];
        return randomPayment;
    } else {
        return nil;
    }
}

- (id)initWithPerson:(MCPerson *)person place:(NSString *)location money:(double)currency
{
    self = [super init];
    
    if (self) {
        money = currency;
        payingPerson = person;
        place = location;
        timePaid = [[NSDate alloc] init];
    }
    
    return self;
}

#pragma mark - Inherited From Super

- (id)init
{
    self = [super init];
    
    if (self) {
        uniquePaymentID = [MCTools createUniqueIdentifierString];
        timePaid = [[NSDate alloc] init];
        money = 0.0;
    }
    
    return self;
}

- (NSString *)description
{
    NSNumberFormatter *numberFormatter= [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSNumber *moneyForString = [[NSNumber alloc] initWithDouble:money];
    return [[NSString alloc] initWithFormat:@"At %@ %@ paid %@.", place, [payingPerson description], [numberFormatter stringFromNumber:moneyForString]];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:uniquePaymentID forKey:@"uniquePaymentID"];
    [aCoder encodeDouble:money forKey:@"money"];
    [aCoder encodeObject:payingPerson forKey:@"payingPerson"];
    [aCoder encodeObject:place forKey:@"place"];
    [aCoder encodeObject:timePaid forKey:@"timePaid"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        [self setUniquePaymentID:[aDecoder decodeObjectForKey:@"uniquePaymentID"]];
        [self setMoney:[aDecoder decodeDoubleForKey:@"money"]];
        [self setPayingPerson:[aDecoder decodeObjectForKey:@"payingPerson"]];
        [self setPlace:[aDecoder decodeObjectForKey:@"place"]];
        timePaid = [aDecoder decodeObjectForKey:@"timePaid"];
    }
    return self;
}

@end
