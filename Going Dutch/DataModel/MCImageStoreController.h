//
//  MCStoreController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 10-04-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MCPerson;
@class MCImage;

@interface MCImageStoreController : NSObject
{
    
}

@property (nonatomic, strong, readonly) NSManagedObjectContext *imageStoreContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *imageStoreModel;

+ (MCImageStoreController *)sharedStore;

- (MCImage *)addThumbnailFromPersonWithId:(NSString *)idString withThumbnail:(UIImage *)thumbnail;
- (MCImage *)addImageFromPersonWithId:(NSString *)idString withThumbnail:(UIImage *)thumbnail andPicture:(UIImage *)picture;
- (MCImage *)fetchImageFromPersonWithId:(NSString *)idString;

- (void)deleteImageObjectFromStore:(MCImage *)image;

- (void)saveStore;

@end
