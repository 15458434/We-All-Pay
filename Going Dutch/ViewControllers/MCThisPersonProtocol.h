//
//  MCThisPersonProtocol.h
//  We all pay
//
//  Created by Mark Cornelisse on 04-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCPerson;

// Notification Message that writableThisPerson is ready to be used.
extern NSString * const MCWritableThisPersonReady;
extern NSString * const MCwritableThisPersonKey;

@protocol MCThisPersonProtocol <NSObject>

// should be executed on the mainThread.
- (MCPerson *)thisPerson;
- (void)setThisPerson:(MCPerson *)person;

// should be executed on the backgroundThread.
- (MCPerson *)writableThisPerson;
- (void)setWritableThisPerson;

- (void)setIsNew:(BOOL)isNew;

@end
