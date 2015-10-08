//
//  MCCategoryPictureStoreController.m
//  We all pay
//
//  Created by Mark Cornelisse on 15/10/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCCategoryPictureStoreController.h"
#import "MCCategoryPictureObject.h"

@implementation MCCategoryPictureStoreController

@synthesize pictureObjects = _pictureObjects;

#pragma mark - Public in this class

- (NSArray<MCCategoryPictureObject *> *)pictureObjects
{
    if (!_pictureObjects) {
        [self preparePictureObjectsArray];
    }
    
    return _pictureObjects;
}

- (void)preparePictureObjectsArray
{
    // This functions loads all data from the plist into the array.
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"categoryPictures" ofType:@"plist"];
    NSArray *arrayFromPlist = [NSArray arrayWithContentsOfFile:plistPath];
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in arrayFromPlist) {
        [resultArray addObject:[MCCategoryPictureObject objectFromDictionary:dict]];
    }
    _pictureObjects = resultArray;
}

#pragma mark - Singleton stuff

+ (id)sharedController {
    static MCCategoryPictureStoreController *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

@end
