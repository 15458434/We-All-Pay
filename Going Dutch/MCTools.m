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
BOOL const showAdsInDebugVersion = YES;
#endif

@implementation MCTools

+ (void)setAdBannerIfNotPaid:(BOOL)show forViewController:(UIViewController *)viewController
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

+ (UIImage *)cutCircularImageFrom:(UIImage *)sourceImage toDestinationRect:(CGRect)newPictureRect
{
    abort();
    UIImage *thisImage = sourceImage;
    NSParameterAssert(thisImage);
    NSParameterAssert(newPictureRect.size.height);
    NSParameterAssert(newPictureRect.size.width);
    CGSize imageSize = [thisImage size];
    float ratio = MAX(newPictureRect.size.width / imageSize.width, newPictureRect.size.height / imageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(newPictureRect.size, NO, 0.0);
    UIBezierPath *circularBezierPath = [UIBezierPath bezierPathWithOvalInRect:newPictureRect];
    [circularBezierPath addClip];
    
    CGRect imageDrawRect;
    imageDrawRect.size.width = ratio * imageSize.width;
    imageDrawRect.size.height = ratio * imageSize.height;
    imageDrawRect.origin.x = (newPictureRect.size.width - imageDrawRect.size.width) / 2.0;
    imageDrawRect.origin.y = (newPictureRect.size.height - imageDrawRect.size.height) / 2.0;
    
    [thisImage drawInRect:imageDrawRect];
    
    UIImage *newPicture = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newPicture;
}

+ (BOOL)isStringAnEmailAddress:(NSString *)stringThatIsSupposedToBeEmailAddress
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

+ (UIColor *)colorWith8BitRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:alpha];
}

@end
