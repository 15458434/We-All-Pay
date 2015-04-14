//
//  MCWhoPayingUserDefaultsStoreInterface.h
//  We all pay
//
//  Created by Mark Cornelisse on 28/11/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const MCWhoIsPayingNextBundleIdentifier;
extern NSString * const MCWeAllPayToWhoIsPayingNextGroupBundleIdentifier;

@interface MCWhoPayingUserDefaultsStoreInterface : NSObject

@property (strong, nonatomic, readonly) NSString *tonightsBillUUID;
@property (strong, nonatomic, readonly) NSString *tripName;

@property (strong, nonatomic, readonly) NSString *nextPayerUUID;
@property (strong, nonatomic, readonly) NSString *fullNameOfNextPayer;

@property (nonatomic, readonly) BOOL valid;
@property (strong, nonatomic, readonly) NSDate *dateSaved;

- (instancetype)initWithTonightsBillUUID:(NSString *)tonightsBillUUID withTripName:(NSString *)tripName andTheNextPayerID:(NSString *)nextPayerUUID withFullName:(NSString *)fullNameOfNextPayer;
- (void)storeToDefaults;
- (BOOL)areAllValuesValid;

@end
