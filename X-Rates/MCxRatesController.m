//
//  MCxRatesController.m
//  We all pay
//
//  Created by Mark Cornelisse on 22-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCxRatesController.h"
#import "MCNetworkTools.h"

// fetchedResult Dictionary keys
NSString * const MCCurrencyExchangeRate = @"exchangeRate";
NSString * const MCFromCountryISOCode = @"from";
NSString * const MCToCountryISOCode = @"to";
NSString * const MCSource = @"source";

// Currency type identify keypath strings.
NSString * const MCCurrencyTypeKeyPathCurrency = @"currency";
NSString * const MCCurrencyTypeKeyPathFundsCode = @"funds code";
NSString * const MCCurrencyTypeKeyPathBondMarketUnit = @"bond market unit";
NSString * const MCCurrencyTypeKeyPathOneTroyOunce = @"one troy ounce";
NSString * const MCCurrencyTypeKeyPathReverseAsset = @"foreing exchange reserve asset";
NSString * const MCCurrencyTypeKeyPathCrypto = @"crypto";
NSString * const MCCurrencyTypeKeyPathComplementaryCurrency = @"complementary currency";
NSString * const MCCurrencyTypeKeyPathUnitOfAccount = @"Unit of Account";
NSString * const MCCurrencyTypeKeyPathSpecialSettlementCurrency = @"special settlement currency";
NSString * const MCCurrencyTypeKeyPathVirtualCurrency = @"Virtual Currency";

// Currency type bitmasks.
NSUInteger const MCCurrencyTypeCurrency = 0x01;
NSUInteger const MCCurrencyTypeFundsCode = 0x02;
NSUInteger const MCCurrencyTypeReverseAsset = 0x04;
NSUInteger const MCCurrencyTypeCrypto = 0x08;
NSUInteger const MCCurrencyTypeOneTroyOunce = 0x10;
NSUInteger const MCCurrencyTypeBondMarketUnit = 0x20;
NSUInteger const MCCurrencyTypeComplementaryCurrency = 0x40;
NSUInteger const MCCurrencyTypeUnitOfAccount = 0x80;
NSUInteger const MCCurrencyTypeSpecialSettlementCurrency = 0x100;
NSUInteger const MCCurrencyTypeVirtualCurrency = 0x200;

// Current hardcoded currencytype selections.
NSUInteger const MCCurrencyTypeSelection = MCCurrencyTypeCurrency | MCCurrencyTypeCrypto;

@interface MCxRatesController ()
{
    NSURLSession *_session;
    NSURLSessionDataTask *_fetchXRatesDataTask;
}

@end

@implementation MCxRatesController

#pragma mark - Class Methods

+ (NSArray *)getAvailableCurrenciesISOCodesOrderedOnCurrencyName
{
    NSDictionary *dictOfValidISOCodes = [MCxRatesController getCurrencyDictionary];
    NSArray *sortedArray = [dictOfValidISOCodes keysSortedByValueUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
        return [obj1[@"name"] compare:obj2[@"name"]];
    }];
    
    return sortedArray;
}

+ (NSDictionary *)getCurrencyDictionary
{
    // Find out the path of recipes.plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Currency info" ofType:@"plist"];
    
    // Load the file content and read the data into arrays
    NSMutableDictionary *currencyDictionaryFromPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
#if DEBUG
    NSUInteger totalAmountInPlist = [[currencyDictionaryFromPlist allKeys] count];
    NSLog(@"Total of %lu in plist", (unsigned long)totalAmountInPlist);
#endif
    NSMutableArray *keyToBeDeletedObjects = [[NSMutableArray alloc] init];
    for (NSString *keyToCurrencyObject in currencyDictionaryFromPlist) {
        if ([keyToCurrencyObject isEqualToString:@"USS"]) {
            NSLog(@"USS is here.");
        }
        NSDictionary *currencyObject = [currencyDictionaryFromPlist objectForKey:keyToCurrencyObject];
        NSString *type = (NSString *)[currencyObject objectForKey:@"type"];
        if ((MCCurrencyTypeCurrency & MCCurrencyTypeSelection) == 0x00) {
            if ([type isEqualToString:MCCurrencyTypeKeyPathCurrency]) {
                NSArray *keysFromObject = [currencyDictionaryFromPlist allKeysForObject:currencyObject];
#if DEBUG
                NSLog(@"%@ with name %@ is of type %@", keyToCurrencyObject, [currencyObject objectForKey:@"name"], type);
#endif
                [keyToBeDeletedObjects addObject:[keysFromObject firstObject]];
                continue;
            }
        }
        if ((MCCurrencyTypeFundsCode & MCCurrencyTypeSelection) == 0x00) {
            if ([type isEqualToString:MCCurrencyTypeKeyPathFundsCode]) {
                NSArray *keysFromObject = [currencyDictionaryFromPlist allKeysForObject:currencyObject];
#if DEBUG
                NSLog(@"%@ with name %@ is of type %@", keyToCurrencyObject, [currencyObject objectForKey:@"name"], type);
#endif
                [keyToBeDeletedObjects addObject:[keysFromObject firstObject]];
                continue;
            }
        }
        if ((MCCurrencyTypeReverseAsset & MCCurrencyTypeSelection) == 0x00) {
            if ([type isEqualToString:MCCurrencyTypeKeyPathReverseAsset]) {
                NSArray *keysFromObject = [currencyDictionaryFromPlist allKeysForObject:currencyObject];
#if DEBUG
                NSLog(@"%@ with name %@ is of type %@", keyToCurrencyObject, [currencyObject objectForKey:@"name"], type);
#endif
                [keyToBeDeletedObjects addObject:[keysFromObject firstObject]];
                continue;
            }
        }
        if ((MCCurrencyTypeCrypto & MCCurrencyTypeSelection) == 0x00) {
            if ([type isEqualToString:MCCurrencyTypeKeyPathCrypto]) {
                NSArray *keysFromObject = [currencyDictionaryFromPlist allKeysForObject:currencyObject];
#if DEBUG
                NSLog(@"%@ with name %@ is of type %@", keyToCurrencyObject, [currencyObject objectForKey:@"name"], type);
#endif
                [keyToBeDeletedObjects addObject:[keysFromObject firstObject]];
                continue;
            }
        }
        if ((MCCurrencyTypeOneTroyOunce & MCCurrencyTypeSelection) == 0x00) {
            if ([type isEqualToString:MCCurrencyTypeKeyPathOneTroyOunce]) {
                NSArray *keysFromObject = [currencyDictionaryFromPlist allKeysForObject:currencyObject];
#if DEBUG
                NSLog(@"%@ with name %@ is of type %@", keyToCurrencyObject, [currencyObject objectForKey:@"name"], type);
#endif
                [keyToBeDeletedObjects addObject:[keysFromObject firstObject]];
                continue;
            }
        }
        if ((MCCurrencyTypeBondMarketUnit & MCCurrencyTypeSelection) == 0x00) {
            if ([type isEqualToString:MCCurrencyTypeKeyPathBondMarketUnit]) {
                NSArray *keysFromObject = [currencyDictionaryFromPlist allKeysForObject:currencyObject];
#if DEBUG
                NSLog(@"%@ with name %@ is of type %@", keyToCurrencyObject, [currencyObject objectForKey:@"name"], type);
#endif
                [keyToBeDeletedObjects addObject:[keysFromObject firstObject]];
                continue;
            }
        }
        if ((MCCurrencyTypeComplementaryCurrency & MCCurrencyTypeSelection) == 0x00) {
            if ([type isEqualToString:MCCurrencyTypeKeyPathComplementaryCurrency]) {
                NSArray *keysFromObject = [currencyDictionaryFromPlist allKeysForObject:currencyObject];
#if DEBUG
                NSLog(@"%@ with name %@ is of type %@", keyToCurrencyObject, [currencyObject objectForKey:@"name"], type);
#endif
                [keyToBeDeletedObjects addObject:[keysFromObject firstObject]];
                continue;
            }
        }
        if ((MCCurrencyTypeUnitOfAccount & MCCurrencyTypeSelection) == 0x00) {
            if ([type isEqualToString:MCCurrencyTypeKeyPathUnitOfAccount]) {
                NSArray *keysFromObject = [currencyDictionaryFromPlist allKeysForObject:currencyObject];
#if DEBUG
                NSLog(@"%@ with name %@ is of type %@", keyToCurrencyObject, [currencyObject objectForKey:@"name"], type);
#endif
                [keyToBeDeletedObjects addObject:[keysFromObject firstObject]];
                continue;
            }
        }
        if ((MCCurrencyTypeSpecialSettlementCurrency & MCCurrencyTypeSelection) == 0x00) {
            if ([type isEqualToString:MCCurrencyTypeKeyPathSpecialSettlementCurrency]) {
                NSArray *keysFromObject = [currencyDictionaryFromPlist allKeysForObject:currencyObject];
#if DEBUG
                NSLog(@"%@ with name %@ is of type %@", keyToCurrencyObject, [currencyObject objectForKey:@"name"], type);
#endif
                [keyToBeDeletedObjects addObject:[keysFromObject firstObject]];
                continue;
            }
        }
        if ((MCCurrencyTypeVirtualCurrency & MCCurrencyTypeSelection) == 0x00) {
            if ([type isEqualToString:MCCurrencyTypeKeyPathVirtualCurrency]) {
                NSArray *keysFromObject = [currencyDictionaryFromPlist allKeysForObject:currencyObject];
#if DEBUG
                NSLog(@"%@ with name %@ is of type %@", keyToCurrencyObject, [currencyObject objectForKey:@"name"], type);
#endif
                [keyToBeDeletedObjects addObject:[keysFromObject firstObject]];
                continue;
            }
        }
    }
    [currencyDictionaryFromPlist removeObjectsForKeys:keyToBeDeletedObjects];
#if DEBUG
    NSUInteger count = currencyDictionaryFromPlist.allKeys.count;
    for (NSString *key in currencyDictionaryFromPlist.allKeys) {
        NSDictionary *currency = [currencyDictionaryFromPlist objectForKey:key];
        NSString *myName = [currency objectForKey:@"name"];
        NSString *myType = [currency objectForKey:@"type"];
        NSLog(@"%@ is named %@ and is of %@", key, myName, myType);
    }
    NSLog(@"%lu of currencies", (unsigned long)count);
#endif
    return currencyDictionaryFromPlist;
}

+ (NSString *)getSymbolForCurrencyISOCode:(NSString *)currencyISOCode
{
    NSString *currencySymbol = [[NSLocale systemLocale] displayNameForKey:NSLocaleCurrencySymbol value:currencyISOCode];
    return currencySymbol;
}

#pragma mark - Private methods

- (void)getExchangeRateFromYahoo:(NSString *)fromCountryISOCode to:(NSString *)toCountryISOCode withCompletionHandler:(void (^)(NSDictionary *))completionBlock
{
    // Either one should be present.
    NSParameterAssert(completionBlock || _xRatesReceiverDelegate);
    if (!fromCountryISOCode || !toCountryISOCode) {
        NSLog(@"Can't fetch when not all currencyISOCodes are available.");
        return;
    }
#ifdef DEBUG
    NSLog(@"Fetching: %@ to %@", fromCountryISOCode, toCountryISOCode);
#endif
    NSString *firstPartOfURLString = @"https://query.yahooapis.com/v1/public/yql?q=select%20rate%2Cname%20from%20csv%20where%20url%3D'http%3A%2F%2Fdownload.finance.yahoo.com%2Fd%2Fquotes%3Fs%3D";
    NSString *secondPartOfURLString = @"%253DX%26f%3Dl1n'%20and%20columns%3D'rate%2Cname'&format=json&diagnostics=true&callback=";
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@", firstPartOfURLString, fromCountryISOCode, toCountryISOCode, secondPartOfURLString];
    
    NSURL *url = [NSURL URLWithString:urlString];
#if TARGET_OS_IPHONE
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
#elif TARGET_OS_MAC
    // There is no networkActivityIndicator on Mac OS X
#endif
    if (_fetchXRatesDataTask) {
        [_fetchXRatesDataTask cancel];
        _fetchXRatesDataTask = nil;
    }
    _fetchXRatesDataTask = [ [NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
#if TARGET_OS_IPHONE
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#elif TARGET_OS_MAC
        // There is no networkActivityIndicator on Mac OS X
#endif
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            if ([httpResp statusCode] == 200) {
                NSError *jsonError;
                NSDictionary *exchangeRateJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                if (jsonError) {
                    completionBlock(nil);
#if TARGET_OS_IPHONE
                    NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
#elif TARGET_OS_MAC
#ifndef EMC_WIDGET
                    NSAlert *jsonAlert = [NSAlert alertWithError:jsonError];
                    [jsonAlert runModal];
#endif
#endif
                } else {
                    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
//                    NSString *localeIdentifier = [exchangeRateJSON valueForKeyPath:@"query.lang"];
                    NSString *localeIdentifier = @"en_US";
                    [numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:localeIdentifier]];
                    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                    NSNumber *exchangeRate = [numberFormatter numberFromString:[exchangeRateJSON valueForKeyPath:@"query.results.row.rate"]];
                    NSDictionary *fetchedResult = @{MCCurrencyExchangeRate: exchangeRate,
                                                    MCFromCountryISOCode: fromCountryISOCode,
                                                    MCToCountryISOCode: toCountryISOCode,
                                                    MCSource: @"YQL"};
                    if (completionBlock) {
                        completionBlock(fetchedResult);
                    } else if (_xRatesReceiverDelegate) {
                        [_xRatesReceiverDelegate postExchangeRate:fetchedResult];
                    }
                }
            } else {
                completionBlock(nil);
                NSLog(@"http response error %ld", (long)[httpResp statusCode]);
            }
        } else {
            NSLog(@"Error: %@", error);
            completionBlock(nil);
#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
#ifndef EMC_WIDGET
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert runModal];
            });
#endif
#endif
        }
    }];
    [_fetchXRatesDataTask resume];
}

- (void)getExchangeRateFromBitcoinAverage:(NSString *)fromCountryISOCode to:(NSString *)toCountryISOCode withCompletionHandler:(void (^)(NSDictionary *))completionBlock
{
    // Either one should be present.
    NSParameterAssert(completionBlock || _xRatesReceiverDelegate);
    if (!fromCountryISOCode || !toCountryISOCode) {
        NSLog(@"Can't fetch when not all currencyISOCodes are available.");
        return;
    }
    NSString *firstString = @"https://api.bitcoinaverage.com/ticker/global/";
    NSString *currencyString;
    if ([fromCountryISOCode isEqualToString:@"BTC"]) {
        currencyString = toCountryISOCode;
    } else if ([toCountryISOCode isEqualToString:@"BTC"]) {
        currencyString = fromCountryISOCode;
    } else {
        // This should not be possible.
        @throw [NSException exceptionWithName:@"Internal error" reason:@"unable to fetch bitcoins if not supplied" userInfo:nil];
    }
    __block NSString *fullURLString = [NSString stringWithFormat:@"%@%@/", firstString, currencyString];
    NSURL *url = [NSURL URLWithString:fullURLString];
#if TARGET_OS_IPHONE
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
#elif TARGET_OS_MAC
    // There is no networkActivityIndicator on Mac OS X
#endif
    if (_fetchXRatesDataTask) {
        [_fetchXRatesDataTask cancel];
        _fetchXRatesDataTask = nil;
    }
    _fetchXRatesDataTask = [ [NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
#if TARGET_OS_IPHONE
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#elif TARGET_OS_MAC
        // There is no networkActivityIndicator on Mac OS X
#endif
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            if ([httpResp statusCode] == 200) {
                NSError *jsonError;
                NSDictionary *exchangeRateJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                if (jsonError) {
#if TARGET_OS_IPHONE
                    NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
#elif TARGET_OS_MAC
#ifndef EMC_WIDGET
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(nil);
                        NSAlert *jsonAlert = [NSAlert alertWithError:jsonError];
                        [jsonAlert runModal];
                    });
#endif
#endif
                } else {
//                    NSNumber *avg24h = [exchangeRateJSON objectForKey:@"24h_avg"];
//                    NSNumber *ask = [exchangeRateJSON objectForKey:@"ask"];
//                    NSNumber *bid = [exchangeRateJSON objectForKey:@"bid"];
                    NSNumber *last = [exchangeRateJSON objectForKey:@"last"];
//                    NSString *timestampString = [exchangeRateJSON objectForKey:@"timestamp"];
//                    NSNumber *volume_btc = [exchangeRateJSON objectForKey:@"volume_btc"];
//                    NSNumber *volume_percent = [exchangeRateJSON objectForKey:@"volume_percent"];
                    NSNumber *exchangeRate;
                    if ([fromCountryISOCode isEqualToString:@"BTC"]) {
                        exchangeRate = @([last doubleValue]);
                    } else if ([toCountryISOCode isEqualToString:@"BTC"]) {
                        exchangeRate = @((double)1.0000 / [last doubleValue]);
                    }
                    NSDictionary *fetchedResult = @{MCCurrencyExchangeRate: exchangeRate,
                                                    MCFromCountryISOCode: fromCountryISOCode,
                                                    MCToCountryISOCode: toCountryISOCode,
                                                    MCSource: @"BitcoinAverage"};
                    if (completionBlock) {
                        completionBlock(fetchedResult);
                    } else if (_xRatesReceiverDelegate) {
                        [_xRatesReceiverDelegate postExchangeRate:fetchedResult];
                    }
                }

            } else {
                completionBlock(nil);
                NSLog(@"http response error %ld", (long)[httpResp statusCode]);
            }
        } else {
#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
#ifndef EMC_WIDGET
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert runModal];
            });
#endif
#endif
        }
    }];
    [_fetchXRatesDataTask resume];
}

#pragma mark - Public methods

- (void)getExchangeRateFrom:(NSString *)fromCountryISOCode to:(NSString *)toCountryISOCode withCompletionHandler:(void (^)(NSDictionary *))completionBlock
{
    // Don't fetch if not two codes are applied.
    if (toCountryISOCode == nil) {
        return;
    }
    if (fromCountryISOCode == nil) {
        return;
    }
    if (isInternetConnection()) {
        if ([fromCountryISOCode isEqualToString:@"BTC"] || [toCountryISOCode isEqualToString:@"BTC"]) {
            [self getExchangeRateFromBitcoinAverage:fromCountryISOCode to:toCountryISOCode withCompletionHandler:completionBlock];
        } else {
            [self getExchangeRateFromYahoo:fromCountryISOCode to:toCountryISOCode withCompletionHandler:completionBlock];
        }
    } else {

    }
}

- (void)cancelAllRunningDataTasks
{
    
}

@end
