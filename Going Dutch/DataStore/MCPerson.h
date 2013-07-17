//
//  MCPerson.h
//  We all pay
//
//  Created by Mark Cornelisse on 12-07-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MCPayment, MCSharedBill;

@interface MCPerson : NSManagedObject
{
    
}

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString * defaultEmailAddress;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) UIImage *picture;
@property (nonatomic, retain) NSData * pictureData;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, retain) NSData * thumbnailData;
@property (nonatomic, retain) NSString * uniquePersonId;
@property (nonatomic, retain) NSSet *payments;
@property (nonatomic, retain) NSSet *sharedBill;
@property (nonatomic, retain) NSSet *emailAddress;

@property (nonatomic, strong) NSNumber *edgeRadius;

+ (MCPerson *)addPerson;
+ (void)deletePerson:(MCPerson *)delPerson;

+ (MCPerson *)fetchPersonWithUniqueId:(NSString *)uuid;

- (void)setThumbnailDataFromImage:(UIImage *)image;
- (void)setPictureDataFromImage:(UIImage *)image;

- (NSString *)getFullName;
- (NSString *)getName;
- (NSString *)defaultEmailAddress;

@end

@interface MCPerson (CoreDataGeneratedAccessors)

- (void)addPaymentsObject:(MCPayment *)value;
- (void)removePaymentsObject:(MCPayment *)value;
- (void)addPayments:(NSSet *)values;
- (void)removePayments:(NSSet *)values;

- (void)addSharedBillObject:(MCSharedBill *)value;
- (void)removeSharedBillObject:(MCSharedBill *)value;
- (void)addSharedBill:(NSSet *)values;
- (void)removeSharedBill:(NSSet *)values;

- (void)addEmailAddressObject:(NSManagedObject *)value;
- (void)removeEmailAddressObject:(NSManagedObject *)value;
- (void)addEmailAddress:(NSSet *)values;
- (void)removeEmailAddress:(NSSet *)values;

@end
