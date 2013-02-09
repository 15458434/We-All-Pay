//
//  MCReturnPayment.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 11-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCPerson;

@interface MCReturnPayment : NSObject
{

}

- (id)initWithPayer:(MCPerson *)p paysTo:(MCPerson *)r amountOfMoney:(double)m;

@property (nonatomic, strong) MCPerson *payer;
@property (nonatomic, strong) MCPerson *receiver;
@property (nonatomic) double money;

@end
