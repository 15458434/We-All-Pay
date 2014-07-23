//
//  MCEmailAddress.h
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MCPerson;

@interface MCEmailAddress : NSManagedObject

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSNumber * selected;
@property (nonatomic, retain) NSString * uniqueEmailId;
@property (nonatomic, retain) MCPerson *owner;

@end
