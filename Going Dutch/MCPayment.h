//
//  MCPayment.h
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MCPerson, MCSharedBill;

@interface MCPayment : NSManagedObject

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString * descriptionOfPayment;
@property (nonatomic, retain) NSNumber * money;
@property (nonatomic, retain) NSString * uniquePaymentId;
@property (nonatomic, retain) MCSharedBill *onWhichBill;
@property (nonatomic, retain) MCPerson *payingPerson;

@end
