//
//  MCCurrency.h
//  We all pay
//
//  Created by Mark Cornelisse on 28-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Foundation;

__deprecated
@interface MCxRatesCurrency : NSObject <NSCoding, NSCopying>

@property (readwrite) NSString *currencyName;
@property (readwrite) NSString *currencySymbol;
@property (readwrite) NSString *currencyISOCode;
@property (readonly) NSString *fullCurrencyName;

@end
