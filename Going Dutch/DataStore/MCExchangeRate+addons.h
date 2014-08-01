//
//  MCExchangeRate+addons.h
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCExchangeRate.h"

@interface MCExchangeRate (addons)

typedef NS_ENUM(short, MCExchangeRateStatus){
    valid,
    invalid,
    fetching
};

+ (MCExchangeRate *)addExchangeRateForContext:(NSManagedObjectContext *)context;

- (BOOL)retrieveExchangeRateFromWeb;

@end
