//
//  MCTools.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 08-04-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCTools.h"
#import "We_all_pay-Swift.h"

#if DEBUG
BOOL const showAdsInDebugVersion = NO;
#endif

@implementation MCTools

+ (void)setAdBannerIfNotPaid:(BOOL)show forViewController:(UIViewController * _Nonnull)viewController
{
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPad"] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [viewController setCanDisplayBannerAds:NO];
    } else {
        // If proProduct is not purchased show banner.
        if (![[MCStoreInterface defaultStoreInterface] isProProductPurchased]) {
#if DEBUG
            if (showAdsInDebugVersion) {
                NSLog(@"Ads will show in debug version.");
                [viewController setCanDisplayBannerAds:show];
            } else {
                NSLog(@"Ads will not show in debug version.");
            }
#else
            NSLog(@"Ads will show.");
            [viewController setCanDisplayBannerAds:show];
#endif
        } else {
            NSLog(@"Ads will not show.");
        }
    }
}

+ (BOOL)isStringAnEmailAddress:(NSString * _Nonnull)stringThatIsSupposedToBeEmailAddress
{
    NSParameterAssert(stringThatIsSupposedToBeEmailAddress);
    if([stringThatIsSupposedToBeEmailAddress length] == 0){
        return NO;
    }
    
    NSString *emailPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRegularExpression *re = [[NSRegularExpression alloc] initWithPattern:emailPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger amountOfMatches = [re numberOfMatchesInString:stringThatIsSupposedToBeEmailAddress options:0 range:NSMakeRange(0, [stringThatIsSupposedToBeEmailAddress length])];
    if (amountOfMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

@end
