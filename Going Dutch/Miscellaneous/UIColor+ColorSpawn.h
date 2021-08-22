//
//  UIColor+ColorSpawn.h
//  We all pay
//
//  Created by Mark Cornelisse on 16/08/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSUInteger, MCColorType) {
    MCColorTypeBackground,
    MCColorTypeButtonEnabled,
    MCColorTypeButtonDisabled,
    MCColorTypeButtonHiglighted,
    MCColorTypeEmptyMessageText,
    MCColorTypeNavigationBar
};

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (ColorSpawn)

+ (UIColor *)colorWithColorType:(MCColorType)type;

@end

NS_ASSUME_NONNULL_END
