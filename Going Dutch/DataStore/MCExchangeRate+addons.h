//
//  MCExchangeRate+addons.h
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCExchangeRate.h"

typedef NS_ENUM(short, MCExchangeRateStatus){
    MCExchangeRateStatusValid NS_SWIFT_NAME(Valid),
    MCExchangeRateStatusInvalid NS_SWIFT_NAME(Invalid),
    MCExchangeRateStatusFetching NS_SWIFT_NAME(Fetching)
};

@interface MCExchangeRate (addons)

+ (MCExchangeRate *)addExchangeRateForContext:(NSManagedObjectContext *)context;

- (void)fetchExchangeRate:(void (^)(NSError *error))completionHandler;

@end
