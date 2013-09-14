//
//  MCEmailAddress.h
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MCPerson;

@interface MCEmailAddress : NSManagedObject

@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSNumber * selected;
@property (nonatomic, retain) NSString * uniqueEmailId;
@property (nonatomic, retain) MCPerson *owner;

@end
