//
//  MCxRatesController.h
//  We all pay
//
//  Created by Mark Cornelisse on 22-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MCxRatesReceiverProtocol <NSObject>

- (void)postExchangeRate:(NSDictionary *)exchangeRateDictionary;

@end

@interface MCxRatesController : NSObject

@property (nonatomic, strong) id<MCxRatesReceiverProtocol> xRatesReceiverDelegate;

+ (NSArray *)getAvailableCurrencies;

- (void)getExchangeRateFrom:(NSString *)fromCountryISOCode to:(NSString *)toCountryISOCode withCompletionHandler:(void (^)(NSDictionary *exchangeRateResult))completionBlock;

@end
