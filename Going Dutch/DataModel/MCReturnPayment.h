//
//  MCReturnPayment.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 11-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCReturnPayment : NSObject
{

}

- (id)initWithPayer:(NSString *)p paysTo:(NSString *)r amountOfMoney:(double)m;

@property (nonatomic, strong) NSString *payer;
@property (nonatomic, strong) NSString *receiver;
@property (nonatomic) double money;

@end
