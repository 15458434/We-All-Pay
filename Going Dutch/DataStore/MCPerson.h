//
//  MCPerson.h
//  We all pay
//
//  Created by Mark Cornelisse on 10-07-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MCPerson : NSManagedObject

@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) UIImage * picture;
@property (nonatomic, retain) NSData * pictureData;
@property (nonatomic, retain) UIImage * thumbnail;
@property (nonatomic, retain) NSData * thumbnailData;
@property (nonatomic, retain) NSString * uniquePersonId;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSSet *payments;
@property (nonatomic, retain) NSSet *sharedBill;

+ (MCPerson *)addPerson;
+ (void)deletePerson:(MCPerson *)delPerson;

+ (MCPerson *)fetchPersonWithUniqueId:(NSString *)uuid;

- (NSString *)getFullName;
- (NSString *)getName;

@end

@interface MCPerson (CoreDataGeneratedAccessors)

- (void)addPaymentsObject:(NSManagedObject *)value;
- (void)removePaymentsObject:(NSManagedObject *)value;
- (void)addPayments:(NSSet *)values;
- (void)removePayments:(NSSet *)values;

- (void)addSharedBillObject:(NSManagedObject *)value;
- (void)removeSharedBillObject:(NSManagedObject *)value;
- (void)addSharedBill:(NSSet *)values;
- (void)removeSharedBill:(NSSet *)values;
@end

@interface MCPerson (TestMethods)

+ (MCPerson *)createRandomPerson;

@end
