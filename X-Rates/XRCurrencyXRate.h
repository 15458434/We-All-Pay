//
//  XRCurrencyXRate.h
//  We all pay
//
//  Created by Mark Cornelisse on 04/09/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int32_t, XRFetchStatus) {
    invalid,
    fetched,
    fetching,
    background,
    failed
};

@interface XRCurrencyXRate : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString *uniqueID;
@property (nonatomic, strong, readonly) NSString *fromCode;
@property (nonatomic, strong, readonly) NSString *toCode;
@property (nonatomic) XRFetchStatus status;
@property (nonatomic, strong) NSNumber *exchangeRate;
@property (nonatomic, strong) NSString *source;

+ (instancetype)xrateWithUniqueID:(NSString *)uniqueID fromCode:(NSString *)fromCode toCode:(NSString *)toCode;
+ (instancetype)xrateWithUniqueID:(NSString *)uniqueID fromCode:(NSString *)fromCode toCode:(NSString *)toCode fromSource:(NSString *)source;
- (instancetype)initWithUniqueID:(NSString *)uniqueID fromCode:(NSString *)fromCode toCode:(NSString *)toCode;
- (instancetype)initWithUniqueID:(NSString *)uniqueID fromCode:(NSString *)fromCode toCode:(NSString *)toCode fromSource:(NSString *)source;

@end
