//
//  MCPaymentPresence.h
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MCPayment, MCPerson;

@interface MCPaymentPresence : NSManagedObject

@property (nonatomic, retain) NSNumber * averageOweFromPayment;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSNumber * isPersonPresent;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) MCPayment *payment;
@property (nonatomic, retain) MCPerson *person;

@end
