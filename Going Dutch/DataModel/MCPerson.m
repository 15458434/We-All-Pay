//
//  MCPerson.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 23-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPerson.h"
#import "MCTools.h"
#import "MCImageStoreController.h"
#import "MCImage.h"

@implementation MCPerson

@synthesize uniquePersonId;
@synthesize firstName;
@synthesize lastName;
@synthesize emailAddress;
@synthesize allEmailAddressesFromAddressBook;

#pragma mark - New in this class

- (void)removePictureData
{
    if (imageObjectFromStore) {
        [[MCImageStoreController sharedStore] deleteImageObjectFromStore:imageObjectFromStore];
    } else {
        NSLog(@"No thumbnail present.");
    }
}

- (UIImage *)thumbnail
{
    if (!imageObjectFromStore) {
        imageObjectFromStore = [[MCImageStoreController sharedStore] fetchImageFromPersonWithId:uniquePersonId];
    }
    return [imageObjectFromStore thumbnail];
}

- (void)setThumbnail:(UIImage *)image
{
    imageObjectFromStore = [[MCImageStoreController sharedStore] addThumbnailFromPersonWithId:[self uniquePersonId] withThumbnail:image];
}

- (UIImage *)picture
{
    if (!imageObjectFromStore) {
        imageObjectFromStore = [[MCImageStoreController sharedStore] fetchImageFromPersonWithId:uniquePersonId];
    }
    return [imageObjectFromStore picture];
}

- (void)setPicture:(UIImage *)image
{
    [imageObjectFromStore setPictureDataFromImage:image];
}

- (id)initWithName:(NSString *)n andMailAddress:(NSString *)ea
{
    self = [super init];
    
    if (self) {
        uniquePersonId = [MCTools createUniqueIdentifierString];
        firstName = n;
        emailAddress = ea;
    }
    return self;
}

- (NSString *)getFullName
{
    if (firstName && lastName) {
        return [[NSString alloc] initWithFormat:@"%@ %@", firstName, lastName];
    } else if (firstName && !lastName) {
        return firstName;
    } else if (!firstName && lastName) {
        return lastName;
    } else  if (emailAddress) {
        return emailAddress;
    } else {
        return @"...";
    }
}

- (NSString *)getName
{
    if (firstName) {
        return firstName;
    } else if (lastName) {
        return lastName;
    } else if (emailAddress) {
        return emailAddress;
    } else {
        return @"...";
    }
}

+ (MCPerson *)createRandomPerson
{
    NSArray *listOfNames = [[NSArray alloc] initWithObjects:@"Lieke", @"Marieke", @"Bas", @"Mark", @"Tineke", @"Merit", @"Arjen", @"Stefan", @"Jeroen", @"Susan", @"Ilse", nil];
    NSUInteger randomNumber = rand() % [listOfNames count];
    return [[MCPerson alloc] initWithName:[listOfNames objectAtIndex:randomNumber] andMailAddress:nil];
}

#pragma mark - Inherited from super.

- (id)init
{
    self = [super init];
    
    if (self) {
        uniquePersonId = [MCTools createUniqueIdentifierString];
    }
    return self;
}

- (id)initWithIdString:(NSString *)idString
{
    self = [super init];
    
    if (self) {
        uniquePersonId = idString;
    }
    return self;
}

- (NSString *)description
{
    return [self getName];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:uniquePersonId forKey:@"uniquePersonId"];
    [aCoder encodeObject:firstName forKey:@"name"];
    [aCoder encodeObject:lastName forKey:@"lastName"];
    [aCoder encodeObject:emailAddress forKey:@"emailAddress"];
    [aCoder encodeObject:allEmailAddressesFromAddressBook forKey:@"allEmailAddressesFromAddressBook"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        uniquePersonId = [aDecoder decodeObjectForKey:@"uniquePersonId"];
        [self setFirstName:[aDecoder decodeObjectForKey:@"name"]];
        [self setLastName:[aDecoder decodeObjectForKey:@"lastName"]];
        [self setEmailAddress:[aDecoder decodeObjectForKey:@"emailAddress"]];
        [self setAllEmailAddressesFromAddressBook:[aDecoder decodeObjectForKey:@"allEmailAddressesFromAddressBook"]];
        imageObjectFromStore = [[MCImageStoreController sharedStore] fetchImageFromPersonWithId:uniquePersonId];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MCPerson *dublicate = [[MCPerson alloc] initWithIdString:[self uniquePersonId]];
    [dublicate setFirstName:[[self firstName] copy]];
    [dublicate setLastName:[[self lastName ] copy]];
    [dublicate setEmailAddress:[[self emailAddress] copy]];
    [dublicate setAllEmailAddressesFromAddressBook:[[self allEmailAddressesFromAddressBook] copy]];
    // This one is not copied, but retrieved again from the store.
    // imageObjectFromStore = [[MCImageStoreController sharedStore] fetchImageFromPersonWithId:[self uniquePersonId]];
    
    
    return dublicate;
}

@end
