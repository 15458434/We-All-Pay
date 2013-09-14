//
//  MCSharedBill.h
//  We all pay
//
//  Created by Mark Cornelisse on 10-07-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MCPerson;
@class MCPayment;
@class MCWeAllPayStoreController;

@interface MCSharedBill : NSManagedObject

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSNumber * hasTheMailBeenSent;
@property (nonatomic, retain) NSString * tripName;
@property (nonatomic, retain) NSString * uniqueBillId;
@property (nonatomic, retain) NSSet *payments;
@property (nonatomic, retain) NSSet *peoplePresent;

@end

@interface MCSharedBill (CoreDataGeneratedAccessors)

- (void)addPaymentsObject:(MCPayment *)value;
- (void)removePaymentsObject:(MCPayment *)value;
- (void)addPayments:(NSSet *)values;
- (void)removePayments:(NSSet *)values;

- (void)addPeoplePresentObject:(MCPerson *)value;
- (void)removePeoplePresentObject:(MCPerson *)value;
- (void)addPeoplePresent:(NSSet *)values;
- (void)removePeoplePresent:(NSSet *)values;

@end

@interface MCSharedBill (TestMessages)

@end
