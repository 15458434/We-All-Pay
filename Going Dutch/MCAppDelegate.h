//
//  MCAppDelegate.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import iAd;

@interface MCAppDelegate : UIResponder <UIApplicationDelegate>
{
    dispatch_once_t executeOnlyOnce;
}

@property (strong, nonatomic) UIWindow *window;

@end
