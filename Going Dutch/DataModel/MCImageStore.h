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

@interface MCImageStore : NSObject
{
    
}

@property (nonatomic, strong, readonly) NSManagedObjectContext *imageStoreContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *imageStoreModel;

+ (MCImageStore *)sharedStore;

- (void)addImageFromPerson:(MCPerson *)person;
- (UIImage *)fetchImageFromIdString:(NSString *)idString;
- (void)deleteImage:(MCPerson *)person;
- (void)saveStore;

@end
