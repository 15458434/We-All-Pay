//
//  MCCategoryPictureObject.m
//  We all pay
//
//  Created by Mark Cornelisse on 15/10/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCCategoryPictureObject.h"

// Dictionary Keys.
NSString const *categoryDescriptionKey = @"categoryDescription";
NSString const *categoryPictureFilenameKey = @"categoryPictureFilename";
NSString const *categoryIdKey = @"categoryId";

@implementation MCCategoryPictureObject

@synthesize smallPicture = _smallPicture;
@synthesize largePicture = _largePicture;

#pragma mark - Public class methods

+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary
{
    return [[MCCategoryPictureObject alloc] initWithDictionary:dictionary];
}

#pragma mark - Public instance methods.

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        NSParameterAssert(dictionary);
        _categoryDescription = [dictionary objectForKey:categoryDescriptionKey];
        NSParameterAssert(_categoryDescription);
        NSNumber *categoryNumber = [dictionary objectForKey:categoryIdKey];
        NSParameterAssert(categoryNumber);
        _categoryId = [categoryNumber shortValue];
        _pictureFilename = [dictionary objectForKey:categoryPictureFilenameKey];
        NSParameterAssert(_pictureFilename);
    }
    return self;
}

- (UIImage *)smallPicture
{
    if (_smallPicture) {
        return _smallPicture;
    }
    
    NSString *filename = [NSString stringWithFormat:@"%@-small", _pictureFilename];
    return [UIImage imageNamed:filename];
}

- (UIImage *)largePicture
{
    if (_largePicture) {
        return _largePicture;
    }
    NSString *filename = [NSString stringWithFormat:@"%@-large", _pictureFilename ];
    return [UIImage imageNamed:filename];
}

@end
