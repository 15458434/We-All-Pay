//
//  MCxRatesController.m
//  We all pay
//
//  Created by Mark Cornelisse on 22-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCxRatesController.h"

@interface MCxRatesController ()
{
    NSURLSession *_session;
}

@end

@implementation MCxRatesController

#pragma mark - Class Methods

+ (NSArray *)getAvailableCurrencies
{
    return [NSLocale ISOCurrencyCodes];
}

#pragma mark - Private methods

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

#pragma mark - Public methods

- (void)getExchangeRateFrom:(NSString *)fromCountryISOCode to:(NSString *)toCountryISOCode withCompletionHandler:(void (^)(NSDictionary *))completionBlock
{
    // Either one should be present.
    NSParameterAssert(completionBlock || _xRatesReceiverDelegate);
    NSString *firstPartOfURLString = @"https://query.yahooapis.com/v1/public/yql?q=select%20rate%2Cname%20from%20csv%20where%20url%3D'http%3A%2F%2Fdownload.finance.yahoo.com%2Fd%2Fquotes%3Fs%3D";
    NSString *secondPartOfURLString = @"%253DX%26f%3Dl1n'%20and%20columns%3D'rate%2Cname'&format=json&diagnostics=true&callback=";
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@", firstPartOfURLString, fromCountryISOCode, toCountryISOCode, secondPartOfURLString];

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionDataTask *dataTask = [ [self session] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            if ([httpResp statusCode] == 200) {
                NSError *jsonError;
                NSDictionary *exchangeRateJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                if (completionBlock) {
                    completionBlock(exchangeRateJSON);
                } else if (_xRatesReceiverDelegate) {
                    [_xRatesReceiverDelegate postExchangeRate:exchangeRateJSON];
                }
            } else {
                NSLog(@"http response error %ld", (long)[httpResp statusCode]);
            }
        } else {
            NSLog(@"NSURLSessionDataTask error: %@", [error localizedDescription]);
        }
    }];
    [dataTask resume];
}

@end
