//
//  SKProduct+MCStoreInterface.h
//  We all pay
//
//  Created by Mark Cornelisse on 16-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface SKProduct (MCStoreInterface)

- (NSString *)priceString;

@end
