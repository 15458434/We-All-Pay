//
//  MCImage.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 11-04-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MCImage : NSManagedObject

// Entity properties.
@property (nonatomic, strong) NSString *uniqueIdentifier;
@property (nonatomic, strong) NSData *thumbnail_data;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSData *picture_data;
@property (nonatomic, strong) UIImage *picture;

// Class properties.
@property (nonatomic, strong) NSNumber *edgeRadius;

- (void)setThumbnailDataFromImage:(UIImage *)image;
- (void)setPictureDataFromImage:(UIImage *)image;

@end
