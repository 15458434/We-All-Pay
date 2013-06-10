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

- (NSUInteger)addPerson:(MCPerson *)newPerson;
- (void)removePerson:(MCPerson *)awfulPerson;
- (void)replacePerson:(MCPerson *)awfulPerson withPerson:(MCPerson *)sweetPerson;
- (void)changeIdentity:(MCPerson *)oldPersonality withIdentity:(MCPerson *)newPersonality;
- (NSArray *)allPeople;
- (BOOL)areTherePeople;
- (BOOL)isPersonWithNamePresent:(MCPerson *)person;
- (NSString *)stringWithNamesOfPeoplePresent;
- (NSString *)stringOfApproxPeoplePresent;
- (BOOL)doesEveryoneHaveAMailAddress;
- (NSArray *)whoHasNoMailAddress;

+ (MCPeople *)createTestGroup;

@end
