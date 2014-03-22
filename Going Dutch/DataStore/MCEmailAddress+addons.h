//
//  MCEmailAddress+addons.h
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCEmailAddress.h"

@interface MCEmailAddress (addons)

+ (MCEmailAddress *)addEmailAddressFor:(MCPerson *)person;
+ (void)deleteEmailAddress:(MCEmailAddress *)eAddress;

+ (MCEmailAddress *)fetchEmailAddressFor:(MCPerson *)person;
+ (BOOL)isTableInDatabaseEmpty;


@end
