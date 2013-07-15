//
//  MCEmailAddress.h
//  We all pay
//
//  Created by Mark Cornelisse on 12-07-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MCPerson;

@interface MCEmailAddress : NSManagedObject

@property (nonatomic, retain) NSString * uniqueEmailId;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSNumber * selected;
@property (nonatomic, retain) MCPerson *owner;

+ (MCEmailAddress *)addEmailAddressFor:(MCPerson *)person;
+ (void)deleteEmailAddress:(MCEmailAddress *)eAddress;

+ (MCEmailAddress *)fetchEmailAddressFor:(MCPerson *)person;

@end
