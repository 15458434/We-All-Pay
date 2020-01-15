//
//  MCGenericInterstitialAdTableViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 14/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

#import "MCGenericInterstitialAdTableViewController.h"

#import "We_all_pay-Swift.h"

@interface MCGenericInterstitialAdTableViewController () <MCInterstitialAdEngineDelegate>

@end

@implementation MCGenericInterstitialAdTableViewController

- (NSString *)adUnitId {
    NSAssert(false, @"Should implement this in the ChildViewController");
    return @"";
}

#pragma mark - MCInterstitialAdEngineDelegate

- (void)willDismissInterstatialFor:(MCInterstitialAdEngine *)adEngine {
    
}

#pragma mark - UITableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        _loadInterstitialOnViewDidLoad = NO;
    }
    return self;
}

#pragma mark - UIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _loadInterstitialOnViewDidLoad = NO;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _loadInterstitialOnViewDidLoad = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_loadInterstitialOnViewDidLoad) {
        [self.adEngine prepareInterstitialwithAdUnitId:self.adUnitId andInterstitialAdEngineDelegate:self];
    }
}

#pragma mark - UIResponder

#pragma mark - NSObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _loadInterstitialOnViewDidLoad = YES;
    }
    return self;
}

@end
