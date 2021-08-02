//
//  MCBorderLineView.h
//  We all pay
//
//  Created by Mark Cornelisse on 20/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
NS_SWIFT_NAME(BorderLineView)
__attribute__((objc_subclassing_restricted))
@interface MCBorderLineView : UIView

@property (nonatomic, strong) IBInspectable UIColor *borderColor;
@property (nonatomic, strong) IBInspectable UIColor *fillColor;

@property (nonatomic) IBInspectable CGFloat dxInset;
@property (nonatomic) IBInspectable CGFloat dyInset;

@property (nonatomic) IBInspectable CGFloat borderCornerRadius;
@property (nonatomic) IBInspectable CGFloat borderWidth;

@end

NS_ASSUME_NONNULL_END
