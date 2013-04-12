//
//  MCTools.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 08-04-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCTools : NSObject

+ (NSString *)createUniqueIdentifierString;
+ (NSURL *)documentPathAsURLTo:(NSString *)fileName;

@end
