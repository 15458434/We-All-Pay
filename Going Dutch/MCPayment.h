//
//  MCSharedPayment.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCReturnPayment;
@class MCPeople;
@class MCPerson;

@interface MCPayment : NSObject
{
    NSString *uniquePaymentID;
    double money;
    MCPerson *payingPerson;
    NSString *place;
    NSDate *timePaid;
}

@property (nonatomic, strong) NSString *uniquePaymentID;
@property (nonatomic) double money;
@property (nonatomic, strong) MCPerson *payingPerson;
@property (nonatomic, strong) NSString *place;
@property (nonatomic, readonly) NSDate *timePaid;

+ (MCPayment *)createRandomPayment;
+ (MCPayment *)createRandomPaymentWithGroup:(MCPeople *)p;

- (id)initWithPerson:(MCPerson *)person place:(NSString *)location money:(double)currency;

- (double)amountPeopleShouldHavePaid:(NSArray *)peoplePresent;

@end
