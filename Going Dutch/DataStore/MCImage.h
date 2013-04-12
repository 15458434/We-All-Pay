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

@property (nonatomic, retain) NSString * uniqueIdentifier;
@property (nonatomic, retain) NSData * thumbnail_data;
@property (nonatomic, strong) UIImage * thumbnail;

- (void)setThumbnailDataFromImage:(UIImage *)image;

@end
