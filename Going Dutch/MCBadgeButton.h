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
@interface MCBadgeButton : UIButton

@property (nonatomic) NSInteger count;
@property (nonatomic, getter=isShowingBadge) IBInspectable BOOL showBadge;

@end

NS_ASSUME_NONNULL_END
