//
//  MCRoundedButton.m
//  We all pay
//
//  Created by Mark Cornelisse on 22/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

#import "MCRoundedButton.h"

@implementation MCRoundedButton

#pragma mark - UIButton

#pragma mark - UIControl

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat dxInset = 17;
        CGFloat dyInset = 6;
        self.contentEdgeInsets = UIEdgeInsetsMake(dyInset, dxInset, dyInset, dxInset);
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGFloat halfHeight = self.bounds.size.height / 2.0;
    UIColor *fillColor = self.isHighlighted ? _highlightedBackgroundColor : _normalBackgroundColor;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGPathRef path = CGPathCreateWithRoundedRect(self.bounds, halfHeight, halfHeight, &CGAffineTransformIdentity);
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextAddPath(context, path);
    CGPathRelease(path);
    CGContextDrawPath(context, kCGPathFill);
    CGContextRestoreGState(context);
    
    [super drawRect:rect];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        CGFloat dxInset = 15;
        CGFloat dyInset = 6;
        self.contentEdgeInsets = UIEdgeInsetsMake(dyInset, dxInset, dyInset, dxInset);
    }
    return self;
}

#pragma mark - UIResponder

#pragma mark - NSObject

- (instancetype)init {
    self = [super init];
    if (self) {
        CGFloat dxInset = 15;
        CGFloat dyInset = 6;
        self.contentEdgeInsets = UIEdgeInsetsMake(dyInset, dxInset, dyInset, dxInset);
    }
    return self;
}

@end
