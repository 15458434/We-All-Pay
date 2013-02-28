//
//  MCPerson.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 23-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPerson.h"

@implementation MCPerson

@synthesize uniquePersonId;
@synthesize picture;
@synthesize thumbnail;
@synthesize name;
@synthesize emailAddress;
@synthesize allEmailAddressesFromAddressBook;

#pragma mark - New in this class

- (id)initWithName:(NSString *)n andMailAddress:(NSString *)ea
{
    self = [super init];
    
    if (self) {
        name = n;
        emailAddress = ea;
    }
    return self;
}

+ (MCPerson *)createRandomPerson
{
    NSArray *listOfNames = [[NSArray alloc] initWithObjects:@"Lieke", @"Marieke", @"Bas", @"Mark", @"Tineke", @"Merit", @"Arjen", @"Stefan", @"Jeroen", @"Susan", @"Ilse", nil];
    NSUInteger randomNumber = rand() % [listOfNames count];
    return [[MCPerson alloc] initWithName:[listOfNames objectAtIndex:randomNumber] andMailAddress:nil];
}

#pragma mark - Inherited from super.

- (NSString *)description
{
    return name;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:uniquePersonId forKey:@"uniquePersonID"];
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:emailAddress forKey:@"emailAddress"];
    [aCoder encodeObject:allEmailAddressesFromAddressBook forKey:@"allEmailAddressesFromAddressBook"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        uniquePersonId = [aDecoder decodeObjectForKey:@"uniquePersonId"];
        [self setName:[aDecoder decodeObjectForKey:@"name"]];
        [self setEmailAddress:[aDecoder decodeObjectForKey:@"emailAddress"]];
        [self setAllEmailAddressesFromAddressBook:[aDecoder decodeObjectForKey:@"allEmailAddressesFromAddressBook"]];
    }
    return self;
}

@end
