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
@synthesize name;
@synthesize emailAddress;
@synthesize allEmailAddressesFromAddressBook;

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
    NSArray *listOfNames = [[NSArray alloc] initWithObjects:@"Lieke", @"Marieke", @"Bas", @"Mark", @"Tineke", @"Merit", @"Arjen", @"Stefan", @"Jeroen", @"Susan", nil];
    NSUInteger randomNumber = rand() % [listOfNames count];
    return [[MCPerson alloc] initWithName:[listOfNames objectAtIndex:randomNumber] andMailAddress:nil];
}

// Inherited from super

- (NSString *)description
{
    return name;
}

@end
