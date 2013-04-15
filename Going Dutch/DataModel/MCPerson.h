//
//  MCPerson.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 23-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@class MCImage;

@interface MCPerson : NSObject <NSCoding>
{
    NSString *uniquePersonId;
    UIImage *picture;
    MCImage *imageObjectFromStore;
    NSString *firstName;
    NSString *lastName;
    NSString *emailAddress;
    NSMutableArray *allEmailAddressesFromAddressBook;
    
}

@property (nonatomic, strong, readonly) NSString *uniquePersonId;
@property (nonatomic, strong) UIImage *picture;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *emailAddress;
@property (nonatomic, strong) NSMutableArray *allEmailAddressesFromAddressBook;


- (id)initWithName:(NSString *)n andMailAddress:(NSString *)ea;
- (NSString *)getFullName;
- (NSString *)getName;
- (UIImage *)thumbnail;
- (void)setThumbnail:(UIImage *)image;
- (void)removeThumbnail;


+ (MCPerson *)createRandomPerson;

@end
