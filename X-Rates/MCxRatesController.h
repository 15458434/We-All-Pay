//
//  MCxRatesController.h
//  We all pay
//
//  Created by Mark Cornelisse on 22-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Foundation;

// fetchedResult Dictionary keys
extern NSString * const MCCurrencyExchangeRate __deprecated;
extern NSString * const MCFromCountryISOCode __deprecated;
extern NSString * const MCToCountryISOCode __deprecated;
extern NSString * const MCSource __deprecated;

extern NSUInteger const MCCurrencyTypeCurrency __deprecated;
extern NSUInteger const MCCurrencyTypeFundsCode __deprecated;
extern NSUInteger const MCCurrencyTypeReverseAsset __deprecated;
extern NSUInteger const MCCurrencyTypeCrypto __deprecated;
extern NSUInteger const MCCurrencyTypeOneTroyOunce __deprecated;
extern NSUInteger const MCCurrencyTypeBondMarketUnit __deprecated;
extern NSUInteger const MCCurrencyTypeComplementaryCurrency __deprecated;
extern NSUInteger const MCCurrencyTypeUnitOfAccount __deprecated;
extern NSUInteger const MCCurrencyTypeSpecialSettlementCurrency __deprecated;
extern NSUInteger const MCCurrencyTypeVirtualCurrency __deprecated;

__deprecated
@protocol MCxRatesReceiverProtocol <NSObject>

- (void)postExchangeRate:(NSDictionary *)exchangeRateDictionary;

@end

__deprecated
@interface MCxRatesController : NSObject

@property (nonatomic, strong) id<MCxRatesReceiverProtocol> xRatesReceiverDelegate;

+ (NSArray *)getAvailableCurrenciesISOCodesOrderedOnCurrencyName;
+ (NSDictionary *)getCurrencyDictionary;
+ (NSString *)getSymbolForCurrencyISOCode:(NSString *)currencyISOCode;

- (void)getExchangeRateFrom:(NSString *)fromCountryISOCode to:(NSString *)toCountryISOCode withCompletionHandler:(void (^)(NSDictionary *exchangeRateResult))completionBlock;

@end
