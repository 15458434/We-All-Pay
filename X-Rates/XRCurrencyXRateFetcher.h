//
//  XRCurrencyXRateFetcher.h
//  We all pay
//
//  Created by Mark Cornelisse on 04/09/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Foundation;



// Fetch ConfigurationConstants. If this value is insterted in fetch configuration it will define the way the currencies will be fetched.
extern short const XRDefaultFetchConfiguration __deprecated;
extern short const XRBackgroundFetchConfiguration __deprecated;

// fetchedResult Dictionary keys
extern NSString * const XRCurrencyExchangeRate __deprecated;
extern NSString * const XRFromCountryISOCode __deprecated;
extern NSString * const XRToCountryISOCode __deprecated;
extern NSString * const XRExchangeRateSource __deprecated;

__deprecated
@interface XRCurrencyXRateFetcher : NSObject

@property (nonatomic) short fetchConfiguration;

- (void)getExchangeRateWithUniqueID:(NSString *)uniqueID from:(NSString *)fromCode to:(NSString *)toCode withCompletionHandler:(void (^)(NSDictionary *exchangeRateResult))completionBlock;

@end
