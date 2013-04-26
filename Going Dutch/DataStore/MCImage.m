//
//  MCImage.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 11-04-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCImage.h"


@implementation MCImage

@dynamic uniqueIdentifier;
@dynamic thumbnail_data;
@dynamic thumbnail;
@dynamic picture_data;
@dynamic picture;

@synthesize edgeRadius;

#pragma mark - New in this class.

- (void)setThumbnailDataFromImage:(UIImage *)image
{
    CGSize imageSize = [image size];
    CGRect thumbnailRect = CGRectMake(0, 0, 44, 44);
    float ratio = MAX(thumbnailRect.size.width / imageSize.width, thumbnailRect.size.height / imageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(thumbnailRect.size, NO, 0.0);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:thumbnailRect cornerRadius:[edgeRadius doubleValue]];
    [bezierPath addClip];
    
    CGRect imageDrawRect;
    imageDrawRect.size.width = ratio * imageSize.width;
    imageDrawRect.size.height = ratio * imageSize.height;
    imageDrawRect.origin.x = (thumbnailRect.size.width - imageDrawRect.size.width) / 2.0;
    imageDrawRect.origin.y = (thumbnailRect.size.height - imageDrawRect.size.height) / 2.0;
    
    [image drawInRect:imageDrawRect];
    UIImage *thumbnailWithRoundedCorners = UIGraphicsGetImageFromCurrentImageContext();
    [self setThumbnail:thumbnailWithRoundedCorners];
    
    NSData *thumbnailWithRoundedCornersData = UIImagePNGRepresentation(thumbnailWithRoundedCorners);
    [self setThumbnail_data:thumbnailWithRoundedCornersData];
    UIGraphicsEndImageContext();
}

- (void)setPictureDataFromImage:(UIImage *)image
{
    CGSize imageSize = [image size];
    CGRect thumbnailRect = CGRectMake(0, 0, 80, 80);
    float ratio = MAX(thumbnailRect.size.width / imageSize.width, thumbnailRect.size.height / imageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(thumbnailRect.size, NO, 0.0);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:thumbnailRect cornerRadius:[edgeRadius doubleValue] * 1.9];
    [bezierPath addClip];
    
    CGRect imageDrawRect;
    imageDrawRect.size.width = ratio * imageSize.width;
    imageDrawRect.size.height = ratio * imageSize.height;
    imageDrawRect.origin.x = (thumbnailRect.size.width - imageDrawRect.size.width) / 2.0;
    imageDrawRect.origin.y = (thumbnailRect.size.height - imageDrawRect.size.height) / 2.0;
    
    [image drawInRect:imageDrawRect];
    UIImage *thumbnailWithRoundedCorners = UIGraphicsGetImageFromCurrentImageContext();
    [self setPicture:thumbnailWithRoundedCorners];
    
    NSData *thumbnailWithRoundedCornersData = UIImagePNGRepresentation(thumbnailWithRoundedCorners);
    [self setPicture_data:thumbnailWithRoundedCornersData];
    UIGraphicsEndImageContext();
}

#pragma mark - Inherited from super.

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    edgeRadius = [NSNumber numberWithDouble:5.0];
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    // Extract the thumbnail image from the data.
    [self setPrimitiveValue:[UIImage imageWithData:[self thumbnail_data]] forKey:@"thumbnail"];
    // Extract the picture image from the data
    [self setPrimitiveValue:[UIImage imageWithData:[self picture_data]] forKey:@"picture"];
    
    edgeRadius = [NSNumber numberWithDouble:5.0];
}

@end
