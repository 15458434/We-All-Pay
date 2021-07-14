//
//  MCBadgeButton.m
//  We all pay
//
//  Created by Mark Cornelisse on 14/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

#import "MCBadgeButton.h"

#import "We_all_pay-Swift.h"

@interface MCBadgeButton ()

@property (nonatomic, strong, nonnull) MCUnreadNotificationsCountView *unreadIndicator;

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
    [self setNeedsDisplay];
}

#pragma mark - UIButton

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
}

- (CGSize)intrinsicContentSize {
    return _normalImage.size;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0, self.normalImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, self.bounds, self.normalImage.CGImage);
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
