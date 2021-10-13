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

__attribute__((objc_subclassing_restricted))
@interface MCPayment : NSManagedObject

@end

@interface MCPayment (CoreDataGeneratedAccessors)

@end
