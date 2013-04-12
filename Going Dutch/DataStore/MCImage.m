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

#pragma mark - New in this class.

- (void)setThumbnailDataFromImage:(UIImage *)image
{
    CGSize originalImageSize = [image size];
    NSLog(@"originalImageSize.width = %f", originalImageSize.width);
    NSLog(@"originalImageSize.witth = %f", originalImageSize.height);
    
}

#pragma mark - Inherited from super.

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    // Extract the thumbnail image from the data.
    UIImage *tn = [UIImage imageWithData:[self thumbnail_data]];
    [self setPrimitiveValue:tn forKey:@"thumbnail"];
}

@end
