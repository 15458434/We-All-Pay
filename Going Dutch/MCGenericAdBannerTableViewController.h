//
//  MCGenericAdBannerTableViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 23/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import GoogleMobileAds;

@class MCAdBannerEngine;

NS_ASSUME_NONNULL_BEGIN

@interface MCGenericAdBannerTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet GADBannerView *worstSalesPitchEverView;
@property (strong, nonatomic) IBOutlet MCAdBannerEngine *adBannerEngine;
@property (nonatomic, readonly) NSString *adUnitId;

@end

NS_ASSUME_NONNULL_END
