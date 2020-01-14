//
//  MCGenericInterstitialAdTableViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 14/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import GoogleMobileAds;

@class MCInterstitialAdEngine;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(GenericInterstitialAdTableViewController)
@interface MCGenericInterstitialAdTableViewController : UITableViewController

@property (nonatomic) BOOL loadInterstitialOnViewDidLoad;
@property (nonatomic, strong) IBOutlet MCInterstitialAdEngine *adEngine;
@property (nonatomic, readonly) NSString *adUnitId;

@end

NS_ASSUME_NONNULL_END
