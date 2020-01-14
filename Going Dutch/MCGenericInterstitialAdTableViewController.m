//
//  MCGenericInterstitialAdTableViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 14/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

#import "MCGenericInterstitialAdTableViewController.h"

@interface MCGenericInterstitialAdTableViewController ()

@end

@implementation MCGenericInterstitialAdTableViewController

- (NSString *)adUnitId {
    NSAssert(false, @"Should implement this in the ChildViewController");
    return @"";
}

#pragma mark - UITableViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.adEngine prepareInterstitialwithAdUnitId:self.adUnitId andViewController:self];
}

#pragma mark - UIResponder

#pragma mark - NSObject

@end
