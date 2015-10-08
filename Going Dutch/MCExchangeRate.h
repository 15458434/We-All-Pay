//
//  MCExchangeRate.h
//  We all pay
//
//  Created by Mark Cornelisse on 01/08/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Foundation;
@import CoreData;

@class MCCurrency, MCPayment;

@interface MCExchangeRate : NSManagedObject

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateFetched;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSNumber * exchangeRate;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) MCCurrency *fromCurrency;
@property (nonatomic, retain) MCPayment *payment;
@property (nonatomic, retain) MCCurrency *toCurrency;

@end
