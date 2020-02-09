//
//  MCGenericMediumAdBannerViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 23/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

#import "MCGenericMediumAdBannerViewController.h"

#import "We_all_pay-Swift.h"

@interface MCGenericMediumAdBannerViewController () <MCAdBannerEngineDelegate>

@end

@implementation MCGenericMediumAdBannerViewController

- (NSString *)adUnitId {
    NSAssert(false, @"Should implement this in the ChildViewController");
    return @"";
}

#pragma mark - MCAdBannerEngineDelegate

- (void)adEngine:(MCAdBannerEngine *)adEngine putOnScreenBannerView:(GADBannerView *)bannerView {
    
}

- (void)adEngine:(MCAdBannerEngine *)adEngine putOffScreenBannerView:(GADBannerView *)bannerView {
    
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_isAdBannerEnabled) {
        [self.adBannerEngine prepareMediumAdBanner:_worstSalesPitchEverView withAdUnitId:self.adUnitId andViewController:self];
    }
}

#pragma mark - UIResponder

#pragma mark - NSObject

@end
