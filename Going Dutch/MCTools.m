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
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    // Add the fileName to the string and return it as a NSURL.
    return [NSURL fileURLWithPath:[documentDirectory stringByAppendingPathComponent:fileName]];
}

+ (void)setAdBannerIfNotPaid:(UIViewController *)viewController
{
    [viewController setCanDisplayBannerAds:YES];
}

@end
