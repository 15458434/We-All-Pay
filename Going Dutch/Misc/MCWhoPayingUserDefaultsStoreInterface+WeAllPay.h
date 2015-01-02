//
//  MCWhoPayingUserDefaultsStoreInterface+WeAllPay.h
//  We all pay
//
//  Created by Mark Cornelisse on 02/01/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

#import "MCWhoPayingUserDefaultsStoreInterface.h"

@class MCSharedBill;

@interface MCWhoPayingUserDefaultsStoreInterface (WeAllPay)

+ (void)sendToUserDefaultsStoreInterface:(MCSharedBill *)tonightsBill;
+ (void)sendInvalidUserDefaultsIfTonightsBillIs:(MCSharedBill *)tonightsBill;

@end
