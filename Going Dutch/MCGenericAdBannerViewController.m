//
//  MCGenericAdBannerViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 10/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

#import "MCGenericAdBannerViewController.h"

@interface MCGenericAdBannerViewController ()



@end

@implementation MCGenericAdBannerViewController

- (NSString *)adUnitId {
    NSAssert(false, @"Should implement this in the ChildViewController");
    return @"";
}

#pragma mark - MCAdEngineDelegate

- (void)adEngine:(MCAdEngine *)adEngine putOnScreenBannerView:(GADBannerView *)bannerView {
    
}

- (void)adEngine:(MCAdEngine *)adEngine putOffScreenBannerView:(GADBannerView *)bannerView {
    
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.adEngine prepareAdBanner:_worstSalesPitchEverView withAdUnitId:self.adUnitId andViewController:self];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    __weak typeof(self) weakSelf = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (MCAdEngine.isEnabled) {
            [weakSelf adEngine:nil putOffScreenBannerView:self.worstSalesPitchEverView];
            [weakSelf.adEngine updateSizeFor:self.worstSalesPitchEverView withScreenSize:size];
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    }];
}

#pragma maek - UIResponder

#pragma maek - NSObject

@end
