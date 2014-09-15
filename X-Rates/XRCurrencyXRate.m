//
//  XRCurrencyXRate.m
//  We all pay
//
//  Created by Mark Cornelisse on 04/09/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "XRCurrencyXRate.h"

NSString * const XRToCode = @"toCode";
NSString * const XRFromCode = @"fromCode";
NSString * const XRStatus = @"status";
NSString * const XRExchangeRate = @"exchangeRate";
NSString * const XRUniqueID = @"uniqueID";
NSString * const XRSource = @"source";

@implementation XRCurrencyXRate

+ (instancetype)xrateWithUniqueID:(NSString *)uniqueID fromCode:(NSString *)fromCode toCode:(NSString *)toCode
{
    return [[XRCurrencyXRate alloc] initWithUniqueID:(NSString *)uniqueID fromCode:(NSString *)fromCode toCode:(NSString *)toCode];
}

+ (instancetype)xrateWithUniqueID:(NSString *)uniqueID fromCode:(NSString *)fromCode toCode:(NSString *)toCode fromSource:(NSString *)source
{
    return [[XRCurrencyXRate alloc] initWithUniqueID:uniqueID fromCode:fromCode toCode:toCode fromSource:source];
}

- (void)setSource:(NSString *)source
{
    if (!_source) {
        _source = [source copy];
    } else {
        NSLog(@"Warning: Unable to set source it is already present.");
    }
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Wrong initializer" reason:@"Use initWithUniqueID instead." userInfo:nil];
}

- (instancetype)initWithUniqueID:(NSString *)uniqueID fromCode:(NSString *)fromCode toCode:(NSString *)toCode
{
    self = [super init];
    if (self) {
        _uniqueID = [uniqueID copy];
        _fromCode = [fromCode copy];
        _toCode = [toCode copy];
    }
    return self;
}

- (instancetype)initWithUniqueID:(NSString *)uniqueID fromCode:(NSString *)fromCode toCode:(NSString *)toCode fromSource:(NSString *)source
{
    self = [super init];
    if (self) {
        _uniqueID = [uniqueID copy];
        _fromCode = [fromCode copy];
        _toCode = [toCode copy];
        _source = [source copy];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        // Decode from data stream.
        _uniqueID = [aDecoder decodeObjectForKey:XRUniqueID];
        _toCode = [aDecoder decodeObjectForKey:XRToCode];
        _fromCode = [aDecoder decodeObjectForKey:XRFromCode];
        _status = [aDecoder decodeInt32ForKey:XRStatus];
        _exchangeRate = [aDecoder decodeObjectForKey:XRExchangeRate];
        _source = [aDecoder decodeObjectForKey:XRSource];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // Encode to data stream.
    [aCoder encodeObject:_uniqueID forKey:XRUniqueID];
    [aCoder encodeObject:_toCode forKey:XRToCode];
    [aCoder encodeObject:_fromCode forKey:XRFromCode];
    [aCoder encodeInt32:_status forKey:XRStatus];
    [aCoder encodeObject:_exchangeRate forKey:XRExchangeRate];
    [aCoder encodeObject:_source forKey:XRSource];
}

@end
