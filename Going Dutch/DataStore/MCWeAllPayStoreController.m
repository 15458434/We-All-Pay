//
//  MCWeAllPayStoreController.m
//  We all pay
//
//  Created by Mark Cornelisse on 08-07-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCWeAllPayStoreController.h"
#import "MCTools.h"

@implementation MCWeAllPayStoreController

@synthesize weAllPayStoreDocument;

#pragma mark - New in this class

+ (MCWeAllPayStoreController *)sharedStore
{
    static MCWeAllPayStoreController *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

#pragma mark - Inherited from super class

- (id)init
{
    self = [super init];
    
    static BOOL stillNeedsInit = 1;
    
    if (self && stillNeedsInit) {
        NSURL *weAllPayURL = [MCTools documentPathAsURLTo:@"WeAllPayStore"];
        weAllPayStoreDocument = [[UIManagedDocument alloc] initWithFileURL:weAllPayURL];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[weAllPayURL path]]) {
            [weAllPayStoreDocument openWithCompletionHandler:^(BOOL success){
                if (!success) {
                    // Handle the error.
                    NSLog(@"Unable to open WeAllPayStore");
                }
            }];
        }
        else {
            // If file doesn't exist. Create it.
            [weAllPayStoreDocument saveToURL:weAllPayURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
                if (!success) {
                    // Handle the error.
                    NSLog(@"Unable to create WeAllPayStore");
                }
            }];
        }
        stillNeedsInit = 0;
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

@end
