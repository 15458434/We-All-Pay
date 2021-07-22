//
//  MCSharedBill.h
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Foundation;
@import CoreData;

@class MCCurrency, MCPayment, MCPerson;

__attribute__((objc_subclassing_restricted))
@interface MCSharedBill : NSManagedObject

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSNumber * hasTheMailBeenSent;
@property (nonatomic, retain) NSString * tripName;
@property (nonatomic, retain) NSString * uniqueBillId;
@property (nonatomic, retain) MCCurrency *mainCurrency;
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
