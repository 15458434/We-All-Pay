//
//  MCCurrency.h
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Foundation;
@import CoreData;

@class MCExchangeRate, MCPayment, MCSharedBill;

__attribute__((objc_subclassing_restricted))
@interface MCCurrency : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSNumber * isStillValid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * symbol;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSSet *exchangeRateFromCurrency;
@property (nonatomic, retain) NSSet *exchangeRateToCurrency;
@property (nonatomic, retain) NSSet *payment;
@property (nonatomic, retain) NSSet *sharedBill;
@end

@interface MCCurrency (CoreDataGeneratedAccessors)

- (void)addExchangeRateFromCurrencyObject:(MCExchangeRate *)value;
- (void)removeExchangeRateFromCurrencyObject:(MCExchangeRate *)value;
- (void)addExchangeRateFromCurrency:(NSSet *)values;
- (void)removeExchangeRateFromCurrency:(NSSet *)values;

- (void)addExchangeRateToCurrencyObject:(MCExchangeRate *)value;
- (void)removeExchangeRateToCurrencyObject:(MCExchangeRate *)value;
- (void)addExchangeRateToCurrency:(NSSet *)values;
- (void)removeExchangeRateToCurrency:(NSSet *)values;

- (void)addPaymentObject:(MCPayment *)value;
- (void)removePaymentObject:(MCPayment *)value;
- (void)addPayment:(NSSet *)values;
- (void)removePayment:(NSSet *)values;

- (void)addSharedBillObject:(MCSharedBill *)value;
- (void)removeSharedBillObject:(MCSharedBill *)value;
- (void)addSharedBill:(NSSet *)values;
- (void)removeSharedBill:(NSSet *)values;

@end
