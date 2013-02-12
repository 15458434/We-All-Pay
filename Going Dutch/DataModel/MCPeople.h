//
//  MCPeople.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 23-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCPerson;

@interface MCPeople : NSObject <NSCoding>
{
    NSMutableArray *people;
}

- (void)addPerson:(MCPerson *)newPerson;
- (void)removePerson:(MCPerson *)awfulPerson;
- (NSArray *)allPeople;
- (BOOL)areTherePeople;
- (BOOL)isPersonWithNamePresent:(MCPerson *)person;

+ (MCPeople *)createTestGroup;

@end
