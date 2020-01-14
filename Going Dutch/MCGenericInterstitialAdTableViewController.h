//
//  MCGenericInterstitialAdTableViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 14/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import GoogleMobileAds;

#import "We_all_pay-Swift.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(GenericInterstitialAdTableViewController)
@interface MCGenericInterstitialAdTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet MCInterstitialAdEngine *adEngine;
@property (nonatomic, readonly) NSString *adUnitId;

@end

NS_ASSUME_NONNULL_END
