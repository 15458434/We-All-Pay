//
//  MCImageFunctions.m
//  We all pay
//
//  Created by Mark Cornelisse on 15/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

#import "MCImageFunctions.h"

UIImage* UIImageCreateImageTemplateWithTintColor(UIImage *image, UIColor *color) {
    CGImageRef cgImage = image.CGImage;
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    uint32_t imageAlphaIndo = kCGImageAlphaPremultipliedLast;
    CGBitmapInfo bitmapInfo = imageAlphaIndo;
    
    size_t roundedWidth = (size_t) round(width);
    size_t roundedHeight = (size_t) round(height);
    CGContextRef context = CGBitmapContextCreate(nil, roundedWidth, roundedHeight, 8, 0, colorSpace, bitmapInfo);
    CGColorSpaceRelease(colorSpace); // Don't need this anymore.
    
    CGContextClipToMask(context, bounds, cgImage);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, bounds);
    
    CGImageRef cgTemplateImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context); // Don't need this anymore.
    UIImage *templateImage = [UIImage imageWithCGImage:cgTemplateImage];
    CGImageRelease(cgTemplateImage); // Don't need this anymore.
    return templateImage;
}
