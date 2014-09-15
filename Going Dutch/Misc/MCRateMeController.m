//
//  MCRateMe.m
//  We all pay
//
//  Created by Mark Cornelisse on 13/09/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCRateMeController.h"

NSString * const MCAmountOfRateMeRequestsKey = @"amountOfRateMeRequestsKey";
NSString * const MCLastSoftwareVersionWithSuccessfulRateMe = @"lastSoftwareVersionWithSuccessfulRateMe";
NSString * const MCDateSuccessfulRateMe = @"dateSuccesfulRateMe";

@interface MCRateMeController()

@property (nonatomic, strong) NSDictionary *historyDictionary;

@end

@implementation MCRateMeController

#pragma mark - Class methods

+ (void)setDefaults
{
    // Should be executed during startup.
    //TODO: Create defaults creation.
}

#pragma mark - Private in object of this class

- (UIAlertController *)prepareRateMeController
{
    // Execute only if version number
    // Check amount of checks since last pop-up.
    // If the on them has passed generate a new one.
    return nil;
}

#pragma mark - Public in object of this class

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Do something here.
        
    }
    return self;
}

@end
