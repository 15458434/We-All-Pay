//
//  MCTools.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 08-04-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import Foundation;
@import UIKit;

__attribute__((objc_subclassing_restricted))
@interface MCTools : NSObject

+ (BOOL)isStringAnEmailAddress:(NSString * _Nonnull)stringThatIsSupposedToBeEmailAddress;

@end
