//
//  MCBadgeButton.m
//  We all pay
//
//  Created by Mark Cornelisse on 14/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

#import "MCBadgeButton.h"
#import "MCImageFunctions.h"

#import <WeAllPayDesignableUI/WeAllPayDesignableUI-Swift.h>

@interface MCBadgeButton ()

@property (nonatomic, strong, nonnull) MCUnreadNotificationsCountView *unreadIndicator;

@property (nonatomic, strong) UIImage *internalNormalImage;
@property (nonatomic, strong) UIImage *internalHighlightedImage;

@end

@implementation MCBadgeButton

- (void)setCount:(NSInteger)count {
    self.unreadIndicator.count = count;
    [self setNeedsLayout];
    BOOL isHidden = (count <= 0);
    NSLog(@"count: %@, isHidden: %@", @(count), @(isHidden));
    self.unreadIndicator.hidden = isHidden;
}

- (NSInteger)count {
    return self.unreadIndicator.count;
}

- (void)setFontColor:(UIColor *)fontColor {
    self.unreadIndicator.textColor = fontColor;
}

- (UIColor *)fontColor {
    return self.unreadIndicator.textColor;
}

- (void)setFontSize:(CGFloat)fontSize {
    self.unreadIndicator.fontSize = fontSize;
}

- (CGFloat)fontSize {
    return self.unreadIndicator.fontSize;
}

- (void)setBadgeColor:(UIColor *)badgeColor {
    self.unreadIndicator.backgroundColor = badgeColor;
}

- (UIColor *)badgeColor {
    return self.unreadIndicator.backgroundColor;
}

- (void)setNormalImage:(UIImage *)normalImage {
    _normalImage = normalImage;
    [self setInternalNormalImage:normalImage];
    if (!_highlightedImage) {
        self.internalHighlightedImage = [self internalImageFromImage:normalImage withColor:_highlightedTintColor];
    }
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
    _highlightedImage = highlightedImage;
    [self setInternalHighlightedImage:highlightedImage];
}


- (void)setHighlightedTintColor:(UIColor *)highlightedTintColor {
    _highlightedTintColor = highlightedTintColor;
    UIImage *result;
    if (!self.highlightedImage) {
        result = [self internalImageFromImage:_normalImage withColor:highlightedTintColor];
    } else {
        result = [self internalImageFromImage:_highlightedImage withColor:highlightedTintColor];
    }
    _internalHighlightedImage = result;
    [self setNeedsDisplay];
}

- (void)setInternalNormalImage:(UIImage *)internalNormalImage {
    if (!internalNormalImage) {
        _internalNormalImage = nil;
        return;
    }
    _internalNormalImage = [self internalImageFromImage:internalNormalImage withColor:self.tintColor];
    [self setNeedsDisplay];
}

- (void)setInternalHighlightedImage:(UIImage *)internalHighlightedImage {
    if (!internalHighlightedImage) {
        _internalHighlightedImage = [self internalImageFromImage:_normalImage withColor:_highlightedTintColor];
        return;
    }
    _internalHighlightedImage = [self internalImageFromImage:internalHighlightedImage withColor:_highlightedTintColor];
    [self setNeedsDisplay];
}

- (UIImage *)internalImageFromImage:(UIImage *)image withColor:(UIColor *)color {
    switch (image.renderingMode) {
        case UIImageRenderingModeAutomatic:
        {
            UIImage *result = UIImageCreateImageTemplateWithTintColor(image, color);
            return result;
        }
            break;
        case UIImageRenderingModeAlwaysOriginal:
            return image;
            break;
        case UIImageRenderingModeAlwaysTemplate:
        {
            UIImage *result = UIImageCreateImageTemplateWithTintColor(image, color);
            return result;
        }
            break;
        default:
            break;
    }
    return image;
}

#pragma mark - UIControl

- (void)setHighlighted:(BOOL)highlighted {
    super.highlighted = highlighted;
    _unreadIndicator.alpha = highlighted ? 0.2 : 1.0;
    [self setNeedsDisplay];
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _unreadIndicator = [[MCUnreadNotificationsCountView alloc] init];
        _unreadIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_unreadIndicator];
        [self.topAnchor constraintEqualToAnchor:_unreadIndicator.topAnchor constant:3].active = YES;
        [self.trailingAnchor constraintEqualToAnchor:_unreadIndicator.trailingAnchor constant:-3].active = YES;
        _unreadIndicator.hidden = YES;
    }
    return self;
}

- (void)setTintColor:(UIColor *)tintColor {
    super.tintColor = tintColor;
    self.unreadIndicator.backgroundColor = tintColor;
    [self setInternalNormalImage:_normalImage];
}

- (CGSize)intrinsicContentSize {
    return _normalImage.size;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIControlState filteredControlState = self.state & 0xFFFF;
    switch (filteredControlState) {
        case UIControlStateHighlighted:
        {
            UIImage *image = _internalHighlightedImage;
            CGContextTranslateCTM(context, 0.0, image.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextDrawImage(context, self.bounds, image.CGImage);
        }
            break;
        default:
        {
            UIImage *image = _internalNormalImage;
            CGContextTranslateCTM(context, 0.0, image.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextDrawImage(context, self.bounds, image.CGImage);
        }
            break;
    }
    CGContextRestoreGState(context);
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _unreadIndicator = [[MCUnreadNotificationsCountView alloc] initWithFrame:self.bounds];
        _unreadIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_unreadIndicator];
        [self.topAnchor constraintEqualToAnchor:_unreadIndicator.topAnchor constant:3].active = YES;
        [self.trailingAnchor constraintEqualToAnchor:_unreadIndicator.trailingAnchor constant:-3].active = YES;
        self.unreadIndicator.hidden = YES;
    }
    return self;
}

#pragma mark - UIResponder

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (@available(iOS 13.0, *)) {
        self.highlighted = YES;
    }
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (@available(iOS 13.0, *)) {
        self.highlighted = NO;
    }
    [super endTrackingWithTouch:touch withEvent:event];
}

#pragma mark - NSObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _unreadIndicator = [[MCUnreadNotificationsCountView alloc] init];
        _unreadIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_unreadIndicator];
        [self.topAnchor constraintEqualToAnchor:_unreadIndicator.topAnchor constant:3].active = YES;
        [self.trailingAnchor constraintEqualToAnchor:_unreadIndicator.trailingAnchor constant:-3].active = YES;
        self.unreadIndicator.hidden = YES;
    }
    return self;
}

@end
