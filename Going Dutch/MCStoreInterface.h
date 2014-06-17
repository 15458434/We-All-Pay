//
//  MCStoreKitInterface.h
//  We all pay
//
//  Created by Mark Cornelisse on 16-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Foundation;
@import StoreKit;
@import Security;

@interface MCStoreInterface : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    NSArray *productIdentifiers;
}

@property (nonatomic, strong) NSString *someProperty;
@property (nonatomic, strong) SKProduct *proProduct;

+ (id)defaultStoreInterface;
+ (BOOL)canMakePayments;

- (void)validateProductIdentifiers;
- (NSString *)getProProductCurrencyString;
- (void)buyProProduct;
- (void)restorePreviousPurchases;

- (BOOL)isProProductPurchased;

@end
