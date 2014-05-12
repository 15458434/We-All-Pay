//
//  MCThisPersonProtocol.h
//  We all pay
//
//  Created by Mark Cornelisse on 04-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCPerson;

@protocol MCThisPersonProtocol <NSObject>

- (MCPerson *)thisPerson;
- (void)setThisPerson:(MCPerson *)person;

@end
