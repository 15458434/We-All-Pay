//
//  MCBadgeButton.h
//  We all pay
//
//  Created by Mark Cornelisse on 14/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
NS_SWIFT_NAME(BadgeButton)
@interface MCBadgeButton : UIControl

@property (nonatomic) IBInspectable NSInteger count;
@property IBInspectable UIColor *fontColor;
@property IBInspectable CGFloat fontSize;
@property IBInspectable UIColor *badgeColor;
@property (nonatomic, getter=isShowingBadge) IBInspectable BOOL showBadge;

@property (nonatomic, strong) IBInspectable UIImage *normalImage;

@end

NS_ASSUME_NONNULL_END
