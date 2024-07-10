//
//  MCEmailAddress.m
//  We all pay
//
//  Created by Mark Cornelisse on 23/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCEmailAddress.h"
#import "MCPerson.h"


@implementation MCEmailAddress

#pragma mark - NSManagedObject

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    [self setPrimitiveValue:NSUUID.UUID.UUIDString forKey:@"uniqueEmailId"];
    NSDate *now = NSDate.date;
    [self setPrimitiveValue:now forKey:@"dateCreated"];
    [self setPrimitiveValue:now forKey:@"dateModified"];
}

#pragma mark - NSObject

@end
