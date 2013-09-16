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
+ (void)deletePerson:(MCPerson *)delPerson;

+ (MCPerson *)fetchPersonWithUniqueId:(NSString *)uuid;

- (void)setThumbnailDataFromImage:(UIImage *)image;
- (void)setPictureDataFromImage:(UIImage *)image;

- (NSString *)getFullName;
- (NSString *)getName;
- (NSString *)defaultEmailAddress;
- (MCEmailAddress *)getDefaultEmailAddressObject;
- (BOOL)isThereAnEmailAddress;

@end
