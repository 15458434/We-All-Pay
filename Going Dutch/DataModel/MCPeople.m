//
//  MCPeople.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 23-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPeople.h"
#import "MCPerson.h"
#import "MCImageStoreController.h"

@implementation MCPeople

#pragma mark - New in this class

- (NSString *)stringWithNamesOfPeoplePresent
{
    NSMutableString *returnString = [[NSMutableString alloc] init];
    for (MCPerson *p in people) {
        NSString *nameString = [[NSString alloc] initWithFormat:@"%@, ", [p getName]];
        [returnString appendString:nameString];
    }
    return returnString;
}

- (NSString *)stringOfApproxPeoplePresent
{
    NSMutableString *returnString = [[NSMutableString alloc] init];
    if ([people count] == 0) {
        return @"No people present.";
    } else if ([people count] == 1) {
        return [[people objectAtIndex:0] getName];
    } else if ([people count] == 2) {
        [returnString appendFormat:@"%@ and %@", [[people objectAtIndex:0] getName], [[people objectAtIndex:1] getName]];
        return returnString;
    } else if ([people count] >= 3) {
        [returnString appendFormat:@"%@, %@ and others", [[people objectAtIndex:0] getName], [[people objectAtIndex:1] getName]];
        return returnString;
    } else {
        @throw [NSException exceptionWithName:@"Negative amount of people." reason:@"Should not be possible." userInfo:nil];
        return nil;
    }
}

- (NSUInteger)addPerson:(MCPerson *)newPerson
{
    // add a person to the array of people and return it's row number.
    [people addObject:newPerson];
    return [people indexOfObject:newPerson];
}

- (void)removePerson:(MCPerson *)awfulPerson
{
    // remove a person from the array of people
    [awfulPerson removeThumbnail];
    [people removeObject:awfulPerson];
}

- (void)replacePerson:(MCPerson *)awfulPerson withPerson:(MCPerson *)sweetPerson
{
    // Replace the person with a new one.
    NSUInteger indexOfPerson = [people indexOfObject:awfulPerson];
    [people replaceObjectAtIndex:indexOfPerson withObject:sweetPerson];
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

- (BOOL)doesEveryoneHaveAMailAddress
{
    BOOL theResult = YES;
    for (MCPerson *p in people) {
        if (![p emailAddress]) {
            theResult = NO;
            NSLog(@"%@ %@ has no mail address.", [p firstName], [p lastName]);
        }
    }
    return theResult;
}

- (NSArray *)whoHasNoMailAddress
{
    NSMutableArray *peopleWithNoMailAddress = [[NSMutableArray alloc] init];
    for (MCPerson *p in people) {
        if (![p emailAddress]) {
            NSLog(@"%@ %@ has no mail address.", [p firstName], [p lastName]);
            [peopleWithNoMailAddress addObject:p];
        }
    }
    return peopleWithNoMailAddress;
}

#pragma mark - Inherited from super class.

- (id)init
{
    self = [super init];
    
    if (self) {
        people = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:people forKey:@"people"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        people = [aDecoder decodeObjectForKey:@"people"];
    }
    return self;
}

@end
