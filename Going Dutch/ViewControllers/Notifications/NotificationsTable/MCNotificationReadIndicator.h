//
//  MCNotificationReadIndicator.h
//  We all pay
//
//  Created by Mark Cornelisse on 13/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
NS_SWIFT_NAME(NotificationReadIndicator)
@interface MCNotificationReadIndicator : UIView

@property (nonatomic, strong) IBInspectable UIColor *indicatorColor;
@property (nonatomic, getter=isShowing) IBInspectable BOOL show;

@end

NS_ASSUME_NONNULL_END
