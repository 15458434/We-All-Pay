//
//  MCRoundedButton.h
//  We all pay
//
//  Created by Mark Cornelisse on 22/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
NS_SWIFT_NAME(RoundedButton)
__attribute__((objc_subclassing_restricted))
@interface MCRoundedButton : UIButton

@property (nonatomic, strong) IBInspectable UIColor *normalBackgroundColor;
@property (nonatomic, strong) IBInspectable UIColor *highlightedBackgroundColor;

@end

NS_ASSUME_NONNULL_END
