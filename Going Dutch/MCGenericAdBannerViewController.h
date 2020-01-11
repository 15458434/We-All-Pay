//
//  MCGenericAdBannerViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 10/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import GoogleMobileAds;

#import "We_all_pay-Swift.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(GenericAdBannerViewController)
@interface MCGenericAdBannerViewController : UIViewController <MCAdEngineDelegate>

@property (weak, nonatomic) IBOutlet GADBannerView *worstSalesPitchEverView;
@property (strong, nonatomic) IBOutlet MCAdEngine *adEngine;
@property (nonatomic, readonly) NSString *adUnitId;

@end

NS_ASSUME_NONNULL_END
