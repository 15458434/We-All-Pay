//
//  MCPayment.h
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Foundation;
@import CoreData;

@class MCCurrency, MCExchangeRate, MCPaymentPresence, MCPerson, MCSharedBill;

@interface MCPayment : NSManagedObject

@property (nonatomic, retain) NSNumber * categoryId;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString * descriptionOfPayment;
@property (nonatomic, retain) NSNumber * money;
@property (nonatomic, retain) NSNumber * moneyInMainCurrency;
@property (nonatomic, retain) NSString * uniquePaymentId;
@property (nonatomic, retain) MCCurrency *currency;
@property (nonatomic, retain) MCExchangeRate *exchangeRate;
@property (nonatomic, retain) MCSharedBill *onWhichBill;
@property (nonatomic, retain) MCPerson *payingPerson;
@property (nonatomic, retain) NSSet *peopleSharingPayment;
@end

@interface MCPayment (CoreDataGeneratedAccessors)

- (void)addPeopleSharingPaymentObject:(MCPaymentPresence *)value;
- (void)removePeopleSharingPaymentObject:(MCPaymentPresence *)value;
- (void)addPeopleSharingPayment:(NSSet *)values;
- (void)removePeopleSharingPayment:(NSSet *)values;

@end
