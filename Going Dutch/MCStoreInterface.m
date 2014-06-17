//
//  MCStoreKitInterface.m
//  We all pay
//
//  Created by Mark Cornelisse on 16-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCStoreInterface.h"

@implementation MCStoreInterface

#pragma mark - Private in this class

- (NSArray *)getProProductIdentifier
{
    if (!productIdentifiers) {
        // They are stored in a property list.
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"Product ids" withExtension:@"plist"];
        productIdentifiers = [NSArray arrayWithContentsOfURL:url];
    }
    return productIdentifiers;
}

- (void)applyProVersion
{
    // The first string is the Pro Version
    NSString *productIdentifier = [[self getProProductIdentifier] firstObject];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@", productIdentifier] object:productIdentifier userInfo:nil];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"The product was bought.");
    [self applyProVersion];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"The sale went bad.");
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"The sale was restored.");
    [self applyProVersion];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark - New and public in this class


- (BOOL)isProProductPurchased
{
    // Verify is ProProduct is Purchased.
    NSString *productIdentifier = [[self getProProductIdentifier] firstObject];
    // If there is no value for that key or when the value for that key is no NO should be the return value.
    return [[NSUserDefaults standardUserDefaults] valueForKey:productIdentifier];
}

+ (BOOL)canMakePayments
{
    // Make it easier inside We all pay.
    return [SKPaymentQueue canMakePayments];
}

- (void)validateProductIdentifiers
{
    NSLog(@"Validating product identifiers.");
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:[self getProProductIdentifier]]];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)buyProProduct
{
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:_proProduct];
    [payment setQuantity:1];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restorePreviousPurchases
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Products Delivered.");
    for (NSString *invalidIdentifier in [response invalidProductIdentifiers]) {
        NSLog(@"Invalid product: %@", invalidIdentifier);
    }
    _proProduct = [[response products] firstObject];
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"updatedTransactions");
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                // Call the appropriate custom method.
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    NSLog(@"removedTransactions");
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"restoreCompletedTransactionsFailedWithError: %@", [error localizedDescription]);
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"paymentQueueRestoreCompletedTransactionsFinished");
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
    NSLog(@"updatedDownloads");
}

#pragma mark - Singleton Methods

+ (id)defaultStoreInterface {
    static MCStoreInterface *defaultStoreInterface = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultStoreInterface = [[self alloc] init];
    });
    return defaultStoreInterface;
}

- (id)init {
    if (self = [super init]) {
        _someProperty = @"Default Property Value";
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

@end
