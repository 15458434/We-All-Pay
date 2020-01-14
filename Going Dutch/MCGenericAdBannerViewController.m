//
//  MCGenericAdBannerViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 10/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

#import "MCGenericAdBannerViewController.h"

#import "We_all_pay-Swift.h"

@interface MCGenericAdBannerViewController () <MCAdBannerEngineDelegate>



@end

@implementation MCGenericAdBannerViewController

- (NSString *)adUnitId {
    NSAssert(false, @"Should implement this in the ChildViewController");
    return @"";
}

#pragma mark - MCAdEngineDelegate

- (void)adEngine:(MCAdBannerEngine *)adEngine putOnScreenBannerView:(GADBannerView *)bannerView {
    
}

- (void)adEngine:(MCAdBannerEngine *)adEngine putOffScreenBannerView:(GADBannerView *)bannerView {
    
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.adBannerEngine prepareAdBanner:_worstSalesPitchEverView withAdUnitId:self.adUnitId andViewController:self];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    __weak typeof(self) weakSelf = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (MCAdEngine.isEnabled) {
            [weakSelf adEngine:nil putOffScreenBannerView:self.worstSalesPitchEverView];
            [weakSelf.adBannerEngine updateSizeFor:self.worstSalesPitchEverView withScreenSize:size];
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    }];
}

#pragma maek - UIResponder

#pragma maek - NSObject

@end
