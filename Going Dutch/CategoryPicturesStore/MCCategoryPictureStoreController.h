//
//  MCCategoryPictureStoreController.h
//  We all pay
//
//  Created by Mark Cornelisse on 15/10/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCCategoryPictureObject;

@interface MCCategoryPictureStoreController : NSObject

@property (nonatomic, strong, readonly, nonnull) NSArray<MCCategoryPictureObject *> *pictureObjects;

+ (instancetype _Nonnull)sharedController;

- (void)preparePictureObjectsArray;

@end
