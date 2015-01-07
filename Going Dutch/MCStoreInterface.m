//
//  MCStoreKitInterface.m
//  We all pay
//
//  Created by Mark Cornelisse on 16-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCStoreInterface.h"

@interface MCStoreInterface () <UIAlertViewDelegate>

@property (nonatomic, strong) SKProductsRequest *productRequest;
@property (nonatomic, strong) NSError *lastSKProductsRequestError;
@property (nonatomic, strong) UIAlertView *appStoreUnreachableAlert;

@end

@implementation MCStoreInterface

#pragma mark - Private in this class

- (NSArray *)getProProductIdentifiers
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
    NSString *productIdentifier = [[self getProProductIdentifiers] firstObject];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    if ([[[transaction payment] productIdentifier] isEqualToString:@"com.Greenhair.We_all_pay.pro"]) {
        NSLog(@"%@ was bought.", [[transaction payment] productIdentifier]);
        [self applyProVersion];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Apply pro version" object:self userInfo:@{@"Kind of purchase" : @"new buy"} ];
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    NSLog(@"The sale went bad: %@", [[transaction error] localizedDescription]);
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    if ([[[[transaction originalTransaction] payment] productIdentifier] isEqualToString:@"com.Greenhair.We_all_pay.pro"]) {
        NSLog(@"The sale of %@ was restored.", [[[transaction originalTransaction] payment] productIdentifier]);
        [self applyProVersion];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Apply pro version" object:self userInfo:@{@"Kind of purchase" : @"restore purchase"} ];
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark - New and public in this class


- (BOOL)isProProductPurchased
{
    // Verify is ProProduct is Purchased.
    NSString *productIdentifier = [[self getProProductIdentifiers] firstObject];
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
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:[self getProProductIdentifiers]]];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)buyProProductSendFrom:(UIViewController *)viewController
{
    if (_proProduct) {
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:_proProduct];
        [payment setQuantity:1];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    } else {
        // Show error message.
        NSString *title = NSLocalizedString(@"App Store unavailable", @"Message that pops up when the App Store is not available.");
        NSString *message = NSLocalizedString(@"Unable to connect to the App Store. Please connect to the internet.", @"Message body explaining the App Store can't be reached.");
        NSString *dismissButtonTitle = NSLocalizedString(@"Dismiss", @"Button that says dismiss.");
        if (NSClassFromString(@"UIAlertController")) {
            // Execute UIAlertController class for displaying error.
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:dismissButtonTitle style:UIAlertViewStyleDefault handler:^(UIAlertAction *action) {
                NSLog(@"App Store unavailable dismissed.");
            }];
            [alertController addAction:dismissAction];
            [viewController presentViewController:alertController animated:YES completion:nil];
        } else {
            // Execute UIAlertView class for displaying error.
            _appStoreUnreachableAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:dismissButtonTitle otherButtonTitles:nil];
            [_appStoreUnreachableAlert show];
        }
    }
}

- (void)restorePreviousPurchases
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _appStoreUnreachableAlert = nil;
}

#pragma mark - SKRequestDelegate

- (void)requestDidFinish:(SKRequest *)request
{
    NSLog(@"%@ did finish", request);
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Request: %@ has failed with error: %@", request, error);
    if ([error.domain isEqualToString:SKErrorDomain]) {
        switch (error.code) {
            case 0:
                NSLog(@"App Store not available.");
                _lastSKProductsRequestError = error;
                break;
            default:
                break;
        }
    }
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Products Delivered.");
    for (NSString *invalidIdentifier in [response invalidProductIdentifiers]) {
        NSLog(@"Invalid product: %@", invalidIdentifier);
    }
    _proProduct = [[response products] firstObject];
    _lastSKProductsRequestError = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Product price" object:self userInfo:@{[_proProduct productIdentifier] : [_proProduct price] } ];
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"updatedTransactions");
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                // Call the appropriate custom method.
            case SKPaymentTransactionStatePurchasing:
                break;
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
    NSLog(@"paymentQueueRestoreCompletedTransactionsFinished %lu", (unsigned long)[[queue transactions] count]);
    if ([[queue transactions] count] == 0) {
        NSLog(@"No previous purchases were restored.");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Restore previous purchases" object:self userInfo:@{@"status" : @"Not restored"} ];
    }
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
