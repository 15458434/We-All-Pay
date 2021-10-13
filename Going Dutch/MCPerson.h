//
//  MCPerson.h
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Foundation;
@import CoreData;
@import UIKit;

@class MCEmailAddress, MCPayment, MCPaymentPresence, MCSharedBill;

__attribute__((objc_subclassing_restricted))
@interface MCPerson : NSManagedObject

@end

@interface MCPerson (CoreDataGeneratedAccessors)

- (void)addEmailAddressObject:(MCEmailAddress *)value;
- (void)removeEmailAddressObject:(MCEmailAddress *)value;
- (void)addEmailAddress:(NSSet *)values;
- (void)removeEmailAddress:(NSSet *)values;

- (void)addPaymentsObject:(MCPayment *)value;
- (void)removePaymentsObject:(MCPayment *)value;
- (void)addPayments:(NSSet *)values;
- (void)removePayments:(NSSet *)values;

- (void)addSharedBillObject:(MCSharedBill *)value;
- (void)removeSharedBillObject:(MCSharedBill *)value;
- (void)addSharedBill:(NSSet *)values;
- (void)removeSharedBill:(NSSet *)values;

- (void)addSharingPaymentObject:(MCPaymentPresence *)value;
- (void)removeSharingPaymentObject:(MCPaymentPresence *)value;
- (void)addSharingPayment:(NSSet *)values;
- (void)removeSharingPayment:(NSSet *)values;

@end
