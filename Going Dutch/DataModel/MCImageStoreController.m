//
//  MCStoreController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 10-04-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCImageStoreController.h"
#import "MCPerson.h"
#import "MCTools.h"
#import "MCImage.h"

@implementation MCImageStoreController

@synthesize imageStoreContext;
@synthesize imageStoreModel;

#pragma mark - New in this class

+ (MCImageStoreController *)sharedStore
{
    static MCImageStoreController *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

- (MCImage *)addImageFromPerson:(NSString *)idString withThumbnail:(UIImage *)thumbnail
{
    NSLog(@"addImageFromPerson executed.");
    MCImage *image = [NSEntityDescription insertNewObjectForEntityForName:@"MCImage" inManagedObjectContext:imageStoreContext];
    [image setUniqueIdentifier:idString];
    [image setThumbnailDataFromImage:thumbnail];
    
    return image;
}

- (UIImage *)fetchImageFromIdString:(NSString *)idString
{
    NSLog(@"fetchImageFromIdString executed.");
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"MCImage" inManagedObjectContext:imageStoreContext]];
    NSString *attributeName = @"uniqueIdentifier";
    NSString *attributeValue = idString;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", attributeName, attributeValue];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *fetchedResult = [[imageStoreContext executeFetchRequest:request error:&error] mutableCopy];
    if (!fetchedResult) {
        NSLog(@"Er ging iets fout bij het ophalen van de thumbnail.");
        return nil;
    } else {
        if ([fetchedResult count] == 0) {
            NSLog(@"No record was found with id:%@", idString);
            return nil;
        }
    }
    return [fetchedResult objectAtIndex:0];
}

- (void)deleteImage:(MCImage *)image
{
    NSLog(@"deleteImage executed.");
    [imageStoreContext deleteObject:image];
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
    
    static BOOL stillNeedsInit = 1;
    
    if (self && stillNeedsInit) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"imageStore" withExtension:@"momd"];
        imageStoreModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
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
        stillNeedsInit = 0;
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

@end
