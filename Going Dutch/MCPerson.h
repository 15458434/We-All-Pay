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

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString * defaultEmailAddress;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * getFullName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) UIImage * picture;
@property (nonatomic, retain) NSData * pictureData;
@property (nonatomic, retain) UIImage * thumbnail;
@property (nonatomic, retain) NSData * thumbnailData;
@property (nonatomic, retain) NSNumber * totalSumPaid;
@property (nonatomic, retain) NSString * uniquePersonId;
@property (nonatomic, retain) NSSet *emailAddress;
@property (nonatomic, retain) NSSet *payments;
@property (nonatomic, retain) NSSet *sharedBill;
@property (nonatomic, retain) NSSet *sharingPayment;
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
