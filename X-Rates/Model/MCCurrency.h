//
//  MCCurrency.h
//  We all pay
//
//  Created by Mark Cornelisse on 28-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Foundation;

@interface MCCurrency : NSObject <NSCoding>

@property (readwrite) NSString *currencyName;
@property (readwrite) NSString *currencySymbol;
@property (readwrite) NSString *currencyISOCode;

@end
