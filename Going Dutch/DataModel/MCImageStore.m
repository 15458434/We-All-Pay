//
//  MCStoreController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 10-04-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCImageStore.h"
#import "MCPerson.h"
#import "MCTools.h"

@implementation MCImageStore

@synthesize imageStoreContext;
@synthesize imageStoreModel;

#pragma mark - New in this class

+ (MCImageStore *)sharedStore
{
    static MCImageStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

- (void)addImageFromPerson:(MCPerson *)person
{
    NSLog(@"addImage executed.");
    
}

- (UIImage *)fetchImageFromIdString:(NSString *)idString
{
    NSLog(@"fetchImageFromIdString executed.");
    return nil;
}

- (void)deleteImage:(MCPerson *)person
{
    NSLog(@"deleteImage executed.");
}

- (void)saveStore
{
    NSLog(@"saveStore executed.");
    NSError *error = nil;
    BOOL successful = [imageStoreContext save:&error];
    if (!successful) {
        [NSException raise:@"Save failed." format:@"Reason: %@", [error localizedDescription]];
    }
}

#pragma mark - Inherited from super class

- (id)init
{
    self = [super init];
    
    if (self) {
        imageStoreModel = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:imageStoreModel];
        
        NSError *error = nil;
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:[MCTools documentPathAsURLTo:@"imageStore"]
                                     options:nil
                                       error:&error]) {
            [NSException raise:@"Open imageStore failed." format:@"Reason: %@", [error localizedDescription]];
        }
        
        imageStoreContext = [[NSManagedObjectContext alloc] init];
        [imageStoreContext setPersistentStoreCoordinator:psc];
        [imageStoreContext setUndoManager:nil];
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

@end
