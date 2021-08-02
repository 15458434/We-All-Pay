//
//  MCBorderLineView.m
//  We all pay
//
//  Created by Mark Cornelisse on 20/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

#import "MCBorderLineView.h"

@implementation MCBorderLineView

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    [self setNeedsDisplay];
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    [self setNeedsDisplay];
}

- (void)setDxInset:(CGFloat)dxInset {
    _dxInset = dxInset;
    [self setNeedsDisplay];
}

- (void)setDyInset:(CGFloat)dyInset {
    _dyInset = dyInset;
    [self setNeedsDisplay];
}

- (void)setBorderCornerRadius:(CGFloat)borderCornerRadius {
    _borderCornerRadius = borderCornerRadius;
    [self setNeedsDisplay];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    [self setNeedsDisplay];
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _borderColor = UIColor.blackColor;
        _fillColor = UIColor.whiteColor;
        _borderWidth = 1;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGRect newRect = CGRectInset(self.bounds, _dxInset, _dyInset);
    CGPathRef path = CGPathCreateWithRoundedRect(newRect, _borderCornerRadius, _borderCornerRadius, &CGAffineTransformIdentity);
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    CGContextSetLineWidth(context, self.borderWidth);
    CGContextAddPath(context, path);
    CGPathRelease(path);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextRestoreGState(context);
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _borderColor = UIColor.blackColor;
        _fillColor = UIColor.whiteColor;
        _borderWidth = 1;
    }
    return self;
}

#pragma mark - UIResponder

#pragma mark - NSObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _borderColor = UIColor.blackColor;
        _fillColor = UIColor.whiteColor;
        _borderWidth = 1;
    }
    return self;
}

@end
