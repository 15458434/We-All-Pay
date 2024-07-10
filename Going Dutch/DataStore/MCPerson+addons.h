//
//  MCPerson+addons.h
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPerson+CoreDataProperties.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCPerson (addons)

+ (void)deletePerson:(MCPerson *)delPerson;

+ (BOOL)isTableInDatabaseEmpty;

- (void)setThumbnailDataFromImage:(nullable UIImage *)image;
- (void)setPictureDataFromImage:(nullable UIImage *)image;

- (NSString *)getFullName;
- (NSString *)getName;
- (nullable NSString *)defaultEmailAddress;
- (void)addNewDefaultEmailAddressFromAString:(NSString *)newEmailAddressString;
- (void)addOneEmailAddressFromAString:(NSString *)emailAddressAsString;
- (nullable MCEmailAddress *)getDefaultEmailAddressObject;
- (void)setNewDefaultEmailaddressObject:(MCEmailAddress *)newDefaultEmailAddress;
- (BOOL)isThereAnEmailAddress;
- (BOOL)hasPersonMadePaymentWithInvalidExchangeRates;

@end

NS_ASSUME_NONNULL_END
