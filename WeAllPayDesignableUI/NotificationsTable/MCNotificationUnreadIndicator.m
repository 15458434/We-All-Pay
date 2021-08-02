//
//  MCNotificationUnreadIndicator.m
//  We all pay
//
//  Created by Mark Cornelisse on 13/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

#import "MCNotificationUnreadIndicator.h"

@implementation MCNotificationUnreadIndicator

- (void)setShow:(BOOL)show {
    [self willChangeValueForKey:@"show"];
    _show = show;
    [self didChangeValueForKey:@"show"];
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _indicatorColor = UIColor.greenColor;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (self.isShowing) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGPathRef path = CGPathCreateWithEllipseInRect(rect, &CGAffineTransformIdentity);
        CGContextSetFillColorWithColor(context, self.indicatorColor.CGColor);
        CGContextAddPath(context, path);
        CGContextDrawPath(context, kCGPathFill);
        CGPathRelease(path);
    }
    [super drawRect:rect];
}

- (CGSize)intrinsicContentSize {
    CGFloat minimalSize = MIN(self.bounds.size.width, self.bounds.size.height);
    return CGSizeMake(minimalSize, minimalSize);
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _indicatorColor = UIColor.greenColor;
    }
    return self;
}

#pragma mark - UIResponder

#pragma mark - NSObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _indicatorColor = UIColor.greenColor;
    }
    return self;
}

#pragma mark - NSKeyValueObserving

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    if ([key isEqualToString:@"show"]) {
        [self setNeedsDisplay];
    }
}

@end
