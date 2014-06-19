//
//  UIView+MCAddons.m
//  We all pay
//
//  Created by Mark Cornelisse on 19-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "UIView+MCAddons.h"

@implementation UIView (MCAddons)

- (UIView *)getFirstResponder
{
    if ([self isFirstResponder])
        return self;
    
    for (UIView *subView in [self subviews]) {
        UIView * subviewWhichIsFirstResponder = [subView getFirstResponder];
        if (subviewWhichIsFirstResponder) {
            return subviewWhichIsFirstResponder;
        }
    }
    
    return nil;
}

@end
