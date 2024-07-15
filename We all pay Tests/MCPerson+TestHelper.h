//
//  MCPerson+TestHelper.h
//  We all pay Tests
//
//  Created by Mark Cornelisse on 16/07/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

#import "MCPerson.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCPerson (TestHelper)

+ (BOOL)isTableInDatabaseEmptyForManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

NS_ASSUME_NONNULL_END
