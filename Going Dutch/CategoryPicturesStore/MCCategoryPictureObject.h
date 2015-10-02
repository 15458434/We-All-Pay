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
@property (nonatomic, strong, readonly, nonnull) NSString *pictureFilename;
@property (nonatomic, strong, readonly, nonnull) NSString *categoryDescription;
@property (nonatomic, strong, readonly, nonnull) UIImage *smallPicture;
@property (nonatomic, strong, readonly, nonnull) UIImage *largePicture;

+ (instancetype _Nonnull)objectFromDictionary:(NSDictionary * _Nonnull)dictionary;

- (instancetype _Nonnull)initWithDictionary:(NSDictionary * _Nonnull)dictionary;

@end
