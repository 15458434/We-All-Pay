//
//  MCWhoPayingUserDefaultsStoreInterface.m
//  We all pay
//
//  Created by Mark Cornelisse on 28/11/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCWhoPayingUserDefaultsStoreInterface.h"

NSString * const MCWhoIsPayingNextBundleIdentifier = @"group.com.GreenHair.We-all-pay.Who-is-paying-next";
NSString * const MCWeAllPayToWhoIsPayingNextGroupBundleIdentifier = @"group.com.GreenHair.We-all-pay.Who-is-paying-next";

NSString * const tonightsBillUUIDKey = @"MCTonightsBillUUIDKey";
NSString * const tripNameKey = @"MCTripNameKey";
NSString * const nextPayerUUIDKey = @"MCNextPayerUUIDKey";
NSString * const fullNameOfNextPayerKey = @"MCFullNameOfNextPayerKey";
NSString * const validKey = @"MCIsTodayExchangeValidKey";
NSString * const dateSavedKey =@"MCDateSavedKey";

@implementation MCWhoPayingUserDefaultsStoreInterface

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self fetchFromUserDefaults];
    }
    return self;
}

- (instancetype)initWithTonightsBillUUID:(NSString *)tonightsBillUUID withTripName:(NSString *)tripName andTheNextPayerID:(NSString *)nextPayerUUID withFullName:(NSString *)fullNameOfNextPayer
{
    self = [super init];
    if (self) {
        _tonightsBillUUID = tonightsBillUUID;
        _tripName = tripName;
        _nextPayerUUID = nextPayerUUID;
        _fullNameOfNextPayer = fullNameOfNextPayer;
        if (self.areAllValuesValid) {
            _valid = YES;
        } else {
            _valid = NO;
        }
    }
    return self;
}

- (void)fetchFromUserDefaults
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:MCWeAllPayToWhoIsPayingNextGroupBundleIdentifier];
    _tonightsBillUUID = [defaults objectForKey:tonightsBillUUIDKey];
    _tripName = [defaults objectForKey:tripNameKey];
    _nextPayerUUID = [defaults objectForKey:nextPayerUUIDKey];
    _fullNameOfNextPayer = [defaults objectForKey:fullNameOfNextPayerKey];
    _valid = [defaults boolForKey:validKey];
    _dateSaved = [defaults objectForKey:dateSavedKey];
}

- (void)storeToDefaults
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:MCWeAllPayToWhoIsPayingNextGroupBundleIdentifier];
    [defaults setObject:_tonightsBillUUID forKey:tonightsBillUUIDKey];
    [defaults setObject:_tripName forKey:tripNameKey];
    [defaults setObject:_nextPayerUUID forKey:nextPayerUUIDKey];
    [defaults setObject:_fullNameOfNextPayer forKey:fullNameOfNextPayerKey];
    [defaults setBool:_valid forKey:validKey];
    _dateSaved = [NSDate date];
    [defaults setObject:_dateSaved forKey:dateSavedKey];
    [defaults synchronize];
}

- (BOOL)areAllValuesValid
{
    if (_tonightsBillUUID && _tripName && _nextPayerUUID && _fullNameOfNextPayer) {
        return YES;
    } else {
        return NO;
    }
}

@end
