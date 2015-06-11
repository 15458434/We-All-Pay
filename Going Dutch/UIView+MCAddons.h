//
//  UIView+MCAddons.h
//  We all pay
//
//  Created by Mark Cornelisse on 19-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import iAd;

@interface UIView (MCAddons)

- (UIView *)getFirstResponder;
- (ADBannerView *)getAdBanner;

@end
