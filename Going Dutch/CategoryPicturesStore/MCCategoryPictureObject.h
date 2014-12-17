//
//  MCCategoryPictureObject.h
//  We all pay
//
//  Created by Mark Cornelisse on 15/10/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCCategoryPictureObject : NSObject

@property (nonatomic, readonly) short categoryId;
@property (nonatomic, strong, readonly) NSString *pictureFilename;
@property (nonatomic, strong, readonly) NSString *categoryDescription;
@property (nonatomic, strong, readonly) UIImage *smallPicture;
@property (nonatomic, strong, readonly) UIImage *largePicture;

+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
