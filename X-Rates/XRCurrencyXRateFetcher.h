//
//  XRCurrencyXRateFetcher.h
//  We all pay
//
//  Created by Mark Cornelisse on 04/09/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Foundation;



// Fetch ConfigurationConstants. If this value is insterted in fetch configuration it will define the way the currencies will be fetched.
extern short const XRDefaultFetchConfiguration;
extern short const XRBackgroundFetchConfiguration;

// fetchedResult Dictionary keys
extern NSString * const XRCurrencyExchangeRate;
extern NSString * const XRFromCountryISOCode;
extern NSString * const XRToCountryISOCode;
extern NSString * const XRExchangeRateSource;

@interface XRCurrencyXRateFetcher : NSObject

@property (nonatomic) short fetchConfiguration;

- (void)getExchangeRateWithUniqueID:(NSString *)uniqueID from:(NSString *)fromCode to:(NSString *)toCode withCompletionHandler:(void (^)(NSDictionary *exchangeRateResult))completionBlock;

@end
