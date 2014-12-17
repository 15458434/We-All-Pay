//
//  MCIndexProtocol.h
//  We all pay
//
//  Created by Mark Cornelisse on 14/11/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MCIndexProtocol <NSObject>
// This protocol is for the presence of an index parameter in an object.

- (NSInteger)index;
- (void)setIndex:(NSInteger)index;

@end

