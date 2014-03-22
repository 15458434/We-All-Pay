//
//  MCPerson+addons.h
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPerson.h"

@interface MCPerson (addons)

+ (MCPerson *)addPerson;
+ (MCPerson *)addPersonInContext:(NSManagedObjectContext *)context;
+ (void)deletePerson:(MCPerson *)delPerson;

+ (MCPerson *)fetchPersonWithUniqueId:(NSString *)uuid;
+ (BOOL)isTableInDatabaseEmpty;

- (void)setThumbnailDataFromImage:(UIImage *)image;
- (void)setPictureDataFromImage:(UIImage *)image;

- (NSString *)getFullName;
- (NSString *)getName;
- (NSString *)defaultEmailAddress;
- (void)addNewDefaultEmailAddressFromAString:(NSString *)newEmailAddressString;
- (void)addOneEmailAddressFromAString:(NSString *)emailAddressAsString;
- (MCEmailAddress *)getDefaultEmailAddressObject;
- (void)deleteEmailAddress:(MCEmailAddress *)eAddress;
- (void)deletAllEmailAddresses;
- (BOOL)isThereAnEmailAddress;

@end
