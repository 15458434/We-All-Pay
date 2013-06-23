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

@synthesize allPeople;

#pragma mark - New in this class

- (NSString *)stringWithNamesOfPeoplePresent
{
    NSMutableString *returnString = [[NSMutableString alloc] init];
    for (MCPerson *p in allPeople) {
        NSString *nameString = [[NSString alloc] initWithFormat:@"%@, ", [p getName]];
        [returnString appendString:nameString];
    }
    return returnString;
}

- (NSString *)stringOfApproxPeoplePresent
{
    NSMutableString *returnString = [[NSMutableString alloc] init];
    if ([allPeople count] == 0) {
        return @"No people present.";
    } else if ([allPeople count] == 1) {
        return [[allPeople objectAtIndex:0] getName];
    } else if ([allPeople count] == 2) {
        [returnString appendFormat:@"%@ and %@", [[allPeople objectAtIndex:0] getName], [[allPeople objectAtIndex:1] getName]];
        return returnString;
    } else if ([allPeople count] >= 3) {
        [returnString appendFormat:@"%@, %@ and others", [[allPeople objectAtIndex:0] getName], [[allPeople objectAtIndex:1] getName]];
        return returnString;
    } else {
        @throw [NSException exceptionWithName:@"Negative amount of people." reason:@"Should not be possible." userInfo:nil];
        return nil;
    }
}

- (NSUInteger)addPerson:(MCPerson *)newPerson
{
    // add a person to the array of people and return it's row number.
    [allPeople addObject:newPerson];
    return [allPeople indexOfObject:newPerson];
}

- (void)removePerson:(MCPerson *)awfulPerson
{
    // remove a person from the array of people
    if (!removedPeople) {
        [awfulPerson removePictureData];
    } else {
        [removedPeople addObject:awfulPerson];
    }
    [allPeople removeObject:awfulPerson];
}

- (void)replacePerson:(MCPerson *)awfulPerson withPerson:(MCPerson *)sweetPerson
{
    // Replace the person with a new one.
    NSUInteger indexOfPerson = [allPeople indexOfObject:awfulPerson];
    [allPeople replaceObjectAtIndex:indexOfPerson withObject:sweetPerson];
}

- (void)changeIdentity:(MCPerson *)oldPersonality withIdentity:(MCPerson *)newPersonality
{
    // bla bla bla dit is poep.
    MCPerson *newPerson = [oldPersonality copyWithZone:nil];
    [newPerson setFirstName:[newPersonality firstName]];
    [newPerson setLastName:[newPersonality lastName]];
    [newPerson setEmailAddress:[newPersonality emailAddress]];
    [newPerson setAllEmailAddressesFromAddressBook:[newPersonality allEmailAddressesFromAddressBook]];
    [newPerson removePictureData];
}

- (BOOL)areTherePeople
{
    if (allPeople == nil) {
        return NO;
    } else {
        if ([allPeople count] == 0) {
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
    for (MCPerson *p in allPeople) {
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
    for (MCPerson *p in allPeople) {
        if (![p emailAddress]) {
            NSLog(@"%@ %@ has no mail address.", [p firstName], [p lastName]);
            [peopleWithNoMailAddress addObject:p];
        }
    }
    return peopleWithNoMailAddress;
}

- (NSUInteger)howManyPeople
{
    return [allPeople count];
}

- (void)setEditing:(BOOL)editing
{
    if (editing) {
        if (!removedPeople) {
            removedPeople = [[NSMutableArray alloc] init];
        }
    } else {
        if (removedPeople) {
            // When editing switched off remove pictures and throw away removePeople array.
            for (MCPerson *p in removedPeople) {
                [p removePictureData];
            }
        }
        removedPeople = nil;
    }
}

- (BOOL)editing
{
    if (removedPeople) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Inherited from super class.

- (id)init
{
    self = [super init];
    
    if (self) {
        allPeople = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:allPeople forKey:@"people"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        allPeople = [aDecoder decodeObjectForKey:@"people"];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MCPeople *dublicate = [[MCPeople alloc] init];
    for (MCPerson *p in allPeople) {
        [dublicate addPerson:[p copy]];
    }
    return dublicate;
}

@end
