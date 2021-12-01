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

@end
