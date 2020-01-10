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

#pragma mark - MCAdEngineDelegate

- (void)putOnScreenBannerView:(GADBannerView *)bannerView {
    
}

- (void)putOffScreenBannerView:(GADBannerView *)bannerview {
    
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.adEngine prepareWithAdBanner:_worstSalesPitchEverView with:self];
}

#pragma maek - UIResponder

#pragma maek - NSObject

@end
