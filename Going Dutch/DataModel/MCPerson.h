//
//  MCPerson.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 23-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface MCPerson : NSObject <NSCoding>
{
    NSString *uniquePersonId;
    NSString *name;
    NSString *emailAddress;
    NSMutableArray *allEmailAddressesFromAddressBook;
}

@property (nonatomic, strong, readonly) NSString *uniquePersonId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *emailAddress;
@property (nonatomic, strong) NSMutableArray *allEmailAddressesFromAddressBook;

- (id)initWithName:(NSString *)n andMailAddress:(NSString *)ea;

+ (MCPerson *)createRandomPerson;

@end
