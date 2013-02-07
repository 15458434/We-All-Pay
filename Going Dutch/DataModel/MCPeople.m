//
//  MCPeople.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 23-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPeople.h"
#import "MCPerson.h"

@implementation MCPeople

// New in this class
- (void)addPerson:(MCPerson *)newPerson
{
    // add a person to the array of people
    [people addObject:newPerson];
}

- (void)removePerson:(MCPerson *)awfulPerson
{
    // remove a person from the array of people
    [people removeObject:awfulPerson];
}

- (NSArray *)allPeople
{
    // Return allPeople as an array.
    return people;
}

- (BOOL)areTherePeople
{
    if (people == nil) {
        return NO;
    } else {
        if ([people count] == 0) {
            return NO;
        } else {
            return YES;
        }
    }
}

- (BOOL)isPersonWithNamePresent:(MCPerson *)person
{
    @throw [NSException exceptionWithName:@"Error" reason:@"isPersonWithNamePresent not implemented yet" userInfo:nil];
    return NO;
}

+ (MCPeople *)createTestGroup
{
    MCPeople *groep = [[MCPeople alloc] init];
    [groep addPerson:[[MCPerson alloc] initWithName:@"Lieke" andMailAddress:nil]];
    [groep addPerson:[[MCPerson alloc] initWithName:@"Marieke" andMailAddress:nil]];
    [groep addPerson:[[MCPerson alloc] initWithName:@"Jeroen" andMailAddress:nil]];
    [groep addPerson:[[MCPerson alloc] initWithName:@"Merit" andMailAddress:nil]];
    [groep addPerson:[[MCPerson alloc] initWithName:@"Rudolf" andMailAddress:nil]];
    [groep addPerson:[[MCPerson alloc] initWithName:@"Iva" andMailAddress:nil]];
    [groep addPerson:[[MCPerson alloc] initWithName:@"Mark" andMailAddress:nil]];
    return groep;
}

// Inherited from Super Class

- (id)init
{
    self = [super init];
    
    if (self) {
        people = [[NSMutableArray alloc] init];
    }
    
    return self;
}

@end
