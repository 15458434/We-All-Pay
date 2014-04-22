//
//  MCTools.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 08-04-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCTools.h"

@implementation MCTools

+ (NSString *)createUniqueIdentifierString
{
    CFUUIDRef UUID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef UUIDString = CFUUIDCreateString(kCFAllocatorDefault, UUID);
    CFRelease(UUID);
    return (__bridge_transfer NSString *)UUIDString;
}

+ (NSString *)documentPathAsURLTo:(NSString *)fileName
{
    // Get the array of document directories.
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // The first document directory in the array is the one used by iOS 6.1.
    NSString *documentDirectory = documentDirectories[0];
    // Add the fileName to the string and return it as a NSURL.
    return [NSURL fileURLWithPath:[documentDirectory stringByAppendingPathComponent:fileName]];
}

+ (void)setAdBannerIfNotPaid:(BOOL)show forViewController:(UIViewController *)viewController
{
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPad"] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [viewController setCanDisplayBannerAds:NO];
    } else {
        [viewController setCanDisplayBannerAds:show];
    }
}

+ (UIImage *)cutCircularImageFrom:(UIImage *)sourceImage toDestinationRect:(CGRect)newPictureRect
{
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

@end
