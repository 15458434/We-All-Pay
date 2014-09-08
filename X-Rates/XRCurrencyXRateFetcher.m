//
//  XRCurrencyXRateFetcher.m
//  We all pay
//
//  Created by Mark Cornelisse on 04/09/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "XRCurrencyXRateFetcher.h"
#import "XRCurrencyXRate.h"
#import "MCNetworkTools.h"

typedef NS_ENUM(short, XRFetchConfiguration) {
    defaultFetchConfiguration,
    backgroundFetchConfiguration
};

// Fetch ConfigurationConstants. If this value is insterted in fetch configuration it will define the way the currencies will be fetched.
short const XRDefaultFetchConfiguration = defaultFetchConfiguration;
short const XRBackgroundFetchConfiguration = backgroundFetchConfiguration;

NSString * const XRExchangeRatesInFetchFile = @"exchangeRatesInFetch";

// fetchedResult Dictionary keys
NSString * const XRCurrencyExchangeRate = @"exchangeRate";
NSString * const XRFromCountryISOCode = @"from";
NSString * const XRToCountryISOCode = @"to";
NSString * const XRExchangeRateSource = @"source";

@interface XRCurrencyXRateFetcher ()

@property (nonatomic, strong) NSMutableArray *exchangeRatesInFetch;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *fetchXRatesDataTask;

@end

@implementation XRCurrencyXRateFetcher

#pragma mark - Private in this class

- (NSURL *)getDocumentURL
{
    NSURL *documentDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [documentDirectory URLByAppendingPathComponent:XRExchangeRatesInFetchFile];
}

- (void)open
{
    _exchangeRatesInFetch = [NSKeyedUnarchiver unarchiveObjectWithFile:[[self getDocumentURL] absoluteString]];
    if (!_exchangeRatesInFetch) {
        _exchangeRatesInFetch = [NSMutableArray new];
    }
}

- (void)save
{
    BOOL success = [NSKeyedArchiver archiveRootObject:_exchangeRatesInFetch toFile:[[self getDocumentURL] absoluteString]];
    if (!success) {
        NSLog(@"Unable to save: %@", XRExchangeRatesInFetchFile);
    }
}

- (NSURLSession *)session
{
    if (_session) {
        return _session;
    } else {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
        return _session;
    }
}

#if TARGET_OS_IPHONE
#pragma mark - iOS
- (void)getExchangeRateFromYahoo:(NSString *)fromCountryISOCode to:(NSString *)toCountryISOCode withCompletionHandler:(void (^)(NSDictionary *))completionBlock
{
    // Either one should be present.
    NSParameterAssert(completionBlock);
    if (!fromCountryISOCode || !toCountryISOCode) {
        NSLog(@"Can't fetch when not all currencyISOCodes are available.");
        return;
    }
    NSString *firstPartOfURLString = @"https://query.yahooapis.com/v1/public/yql?q=select%20rate%2Cname%20from%20csv%20where%20url%3D'http%3A%2F%2Fdownload.finance.yahoo.com%2Fd%2Fquotes%3Fs%3D";
    NSString *secondPartOfURLString = @"%253DX%26f%3Dl1n'%20and%20columns%3D'rate%2Cname'&format=json&diagnostics=true&callback=";
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@", firstPartOfURLString, fromCountryISOCode, toCountryISOCode, secondPartOfURLString];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if (_fetchXRatesDataTask) {
        [_fetchXRatesDataTask cancel];
        _fetchXRatesDataTask = nil;
    }
    _fetchXRatesDataTask = [ [self session] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            if ([httpResp statusCode] == 200) {
                NSError *jsonError;
                NSDictionary *exchangeRateJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                if (jsonError) {
                    NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                } else {
                    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
                    NSString *localeIdentifier = [exchangeRateJSON valueForKeyPath:@"query.lang"];
                    [numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:localeIdentifier]];
                    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                    NSNumber *exchangeRate = [numberFormatter numberFromString:[exchangeRateJSON valueForKeyPath:@"query.results.row.rate"]];
                    NSDictionary *fetchedResult = @{XRCurrencyExchangeRate: exchangeRate,
                                                    XRFromCountryISOCode: fromCountryISOCode,
                                                    XRToCountryISOCode: toCountryISOCode,
                                                    XRExchangeRateSource: @"YQL"};
                    if (completionBlock) {
                        completionBlock(fetchedResult);
                    }
                }
            } else {
                NSLog(@"http response error %ld", (long)[httpResp statusCode]);
            }
        } else {
            
        }
    }];
    [_fetchXRatesDataTask resume];
}

- (void)getExchangeRateFromBitcoinAverage:(NSString *)fromCountryISOCode to:(NSString *)toCountryISOCode withCompletionHandler:(void (^)(NSDictionary *))completionBlock
{
    // Either one should be present.
    NSParameterAssert(completionBlock);
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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if (_fetchXRatesDataTask) {
        [_fetchXRatesDataTask cancel];
        _fetchXRatesDataTask = nil;
    }
    _fetchXRatesDataTask = [ [self session] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            if ([httpResp statusCode] == 200) {
                NSError *jsonError;
                NSDictionary *exchangeRateJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                if (jsonError) {
                    NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
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
                    NSDictionary *fetchedResult = @{XRCurrencyExchangeRate: exchangeRate,
                                                    XRFromCountryISOCode: fromCountryISOCode,
                                                    XRToCountryISOCode: toCountryISOCode,
                                                    XRExchangeRateSource: @"BitcoinAverage"};
                    if (completionBlock) {
                        completionBlock(fetchedResult);
                    }
                }
            } else {
                NSLog(@"http response error %ld", (long)[httpResp statusCode]);
            }
        } else {
        }
    }];
    [_fetchXRatesDataTask resume];
}

#elif TARGET_OS_MAC
#pragma mark - OS X
- (void)getExchangeRateFromYahoo:(NSString *)fromCountryISOCode to:(NSString *)toCountryISOCode withCompletionHandler:(void (^)(NSDictionary *))completionBlock
{
    // Either one should be present.
    NSParameterAssert(completionBlock);
    if (!fromCountryISOCode || !toCountryISOCode) {
        NSLog(@"Can't fetch when not all currencyISOCodes are available.");
        return;
    }
    NSString *firstPartOfURLString = @"https://query.yahooapis.com/v1/public/yql?q=select%20rate%2Cname%20from%20csv%20where%20url%3D'http%3A%2F%2Fdownload.finance.yahoo.com%2Fd%2Fquotes%3Fs%3D";
    NSString *secondPartOfURLString = @"%253DX%26f%3Dl1n'%20and%20columns%3D'rate%2Cname'&format=json&diagnostics=true&callback=";
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@", firstPartOfURLString, fromCountryISOCode, toCountryISOCode, secondPartOfURLString];
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (_fetchXRatesDataTask) {
        [_fetchXRatesDataTask cancel];
        _fetchXRatesDataTask = nil;
    }
    _fetchXRatesDataTask = [ [self session] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            if ([httpResp statusCode] == 200) {
                NSError *jsonError;
                NSDictionary *exchangeRateJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                if (jsonError) {
                    NSAlert *jsonAlert = [NSAlert alertWithError:jsonError];
                    [jsonAlert runModal];
                } else {
                    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
                    NSString *localeIdentifier = [exchangeRateJSON valueForKeyPath:@"query.lang"];
                    [numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:localeIdentifier]];
                    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                    NSNumber *exchangeRate = [numberFormatter numberFromString:[exchangeRateJSON valueForKeyPath:@"query.results.row.rate"]];
                    NSDictionary *fetchedResult = @{XRCurrencyExchangeRate: exchangeRate,
                                                    XRFromCountryISOCode: fromCountryISOCode,
                                                    XRToCountryISOCode: toCountryISOCode,
                                                    XRExchangeRateSource: @"YQL"};
                    if (completionBlock) {
                        completionBlock(fetchedResult);
                    }
                }
            } else {
                NSLog(@"http response error %ld", (long)[httpResp statusCode]);
            }
        } else {
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert runModal];
        }
    }];
    [_fetchXRatesDataTask resume];
}

- (void)getExchangeRateFromBitcoinAverage:(NSString *)fromCountryISOCode to:(NSString *)toCountryISOCode withCompletionHandler:(void (^)(NSDictionary *))completionBlock
{
    // Either one should be present.
    NSParameterAssert(completionBlock);
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
    if (_fetchXRatesDataTask) {
        [_fetchXRatesDataTask cancel];
        _fetchXRatesDataTask = nil;
    }
    _fetchXRatesDataTask = [ [self session] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            if ([httpResp statusCode] == 200) {
                NSError *jsonError;
                NSDictionary *exchangeRateJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                if (jsonError) {
                    NSAlert *jsonAlert = [NSAlert alertWithError:jsonError];
                    [jsonAlert runModal];
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
                    NSDictionary *fetchedResult = @{XRCurrencyExchangeRate: exchangeRate,
                                                    XRFromCountryISOCode: fromCountryISOCode,
                                                    XRToCountryISOCode: toCountryISOCode,
                                                    XRExchangeRateSource: @"BitcoinAverage"};
                    if (completionBlock) {
                        completionBlock(fetchedResult);
                    }
                }
            } else {
                NSLog(@"http response error %ld", (long)[httpResp statusCode]);
            }
        } else {
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert runModal];
        }
    }];
    [_fetchXRatesDataTask resume];
}
#endif

#pragma mark - Public in this class

- (void)getExchangeRateWithUniqueID:(NSString *)uniqueID from:(NSString *)fromCode to:(NSString *)toCode withCompletionHandler:(void (^)(NSDictionary *))completionBlock
{
    // TODO: At an exchangeRate to the Array and removed it when fetched, but not when failed.
    // Don't fetch if not two codes are applied.
    if (toCode == nil || fromCode == nil) {
        // When either value is nil nothing should be fetched.
        return;
    }
    
    XRCurrencyXRate *xRate;
    
    if (isInternetConnection()) {
        if ([fromCode isEqualToString:@"BTC"] || [toCode isEqualToString:@"BTC"]) {
            xRate = [[XRCurrencyXRate alloc] initWithUniqueID:uniqueID fromCode:fromCode toCode:toCode fromSource:@"BitcoinAverage"];
            xRate.status = fetching;
            [self getExchangeRateFromBitcoinAverage:fromCode to:toCode withCompletionHandler:completionBlock];
        } else {
            xRate = [[XRCurrencyXRate alloc] initWithUniqueID:uniqueID fromCode:fromCode toCode:toCode fromSource:@"YQL"];
            xRate.status = fetching;
            [self getExchangeRateFromYahoo:fromCode to:toCode withCompletionHandler:completionBlock];
        }
    } else {
        if ([fromCode isEqualToString:@"BTC"] || [toCode isEqualToString:@"BTC"]) {
            xRate = [[XRCurrencyXRate alloc] initWithUniqueID:uniqueID fromCode:fromCode toCode:toCode fromSource:@"BitcoinAverage"];
            xRate.status = failed;
            completionBlock(nil);
        } else {
            xRate = [[XRCurrencyXRate alloc] initWithUniqueID:uniqueID fromCode:fromCode toCode:toCode fromSource:@"YQL"];
            xRate.status = failed;
            completionBlock(nil);
        }
    }
    [_exchangeRatesInFetch addObject:xRate];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self open];
    }
    return self;
}

- (void)dealloc
{
    [self save];
}

@end
