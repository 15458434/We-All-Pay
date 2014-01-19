//
//  MCWeAllPayStoreController.m
//  We all pay
//
//  Created by Mark Cornelisse on 08-07-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCWeAllPayStoreController.h"
//#import "MCTools.h"
#import "MCPerson.h"
#import "MCPayment.h"
#import "MCSharedBill.h"

@implementation MCWeAllPayStoreController

@synthesize weAllPayStoreDocument;

#pragma mark - Internal methods



#pragma mark - New in this class

- (void)storeIsReady:(NSNotification *)notification
{
    if ([weAllPayStoreDocument documentState] == UIDocumentStateNormal) {
        NSLog(@"Document is ready to use.");
    }
}

+ (MCWeAllPayStoreController *)defaultStore
{
    static MCWeAllPayStoreController *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    } /*else {
        if ([[sharedStore weAllPayStoreDocument] documentState] == UIDocumentStateClosed) {
            [[sharedStore weAllPayStoreDocument] openWithCompletionHandler:^(BOOL success){
                if (!success) {
                    NSLog(@"Something went wrong opening your document.");
                }
            }];
        }
    }*/
    return sharedStore;
}

- (void)saveStore
{
    [weAllPayStoreDocument saveToURL:[weAllPayStoreDocument fileURL] forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (success) {
            NSLog(@"Succesfully saved.");
        } else {
            NSLog(@"Save not possible for document at %@", [weAllPayStoreDocument fileURL]);
        }
    }];
}

- (void)closeDocument
{
    [weAllPayStoreDocument closeWithCompletionHandler:^(BOOL success){
        if (success) {
            NSLog(@"UIManagedDocument was succesfully closed.");
        } else {
            NSLog(@"Close not possible for document at %@", [weAllPayStoreDocument fileURL]);
        }
    }];
}

- (BOOL)isDocumentStateNormal
{
    if ([weAllPayStoreDocument documentState] == UIDocumentStateNormal) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Inherited from super class

- (id)init
{
    self = [super init];
    
    static BOOL stillNeedsInit = 1;
    
    if (self && stillNeedsInit) {
        NSURL *weAllPayURL = [MCTools documentPathAsURLTo:@"WeAllPayStore"];
        weAllPayStoreDocument = [[UIManagedDocument alloc] initWithFileURL:weAllPayURL];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeIsReady:) name:UIDocumentStateChangedNotification object:weAllPayStoreDocument];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[[weAllPayStoreDocument fileURL] path]]) {
            [weAllPayStoreDocument saveToURL:[weAllPayStoreDocument fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                if (success) {
                    NSLog(@"Successful SaveForCreating");
                    [[weAllPayStoreDocument managedObjectContext] setUndoManager:[[NSUndoManager alloc] init]];
                    [[[weAllPayStoreDocument managedObjectContext] undoManager] disableUndoRegistration];
                } else {
                    NSLog(@"SaveForCreating not successful.");
                }
            }];
        } else if ([weAllPayStoreDocument documentState] == UIDocumentStateClosed) {
            [weAllPayStoreDocument openWithCompletionHandler:^(BOOL success) {
                if (success) {
                    NSLog(@"Succesful Open");
                    [[weAllPayStoreDocument managedObjectContext] setUndoManager:[[NSUndoManager alloc] init]];
                    [[[weAllPayStoreDocument managedObjectContext] undoManager] disableUndoRegistration];
                } else {
                    NSLog(@"Open not successful");
                }
            }];
        } else if ([weAllPayStoreDocument documentState] == UIDocumentStateNormal) {
            NSLog(@"DocumentState is already normal.");
            [[weAllPayStoreDocument managedObjectContext] setUndoManager:[[NSUndoManager alloc] init]];
            [[[weAllPayStoreDocument managedObjectContext] undoManager] disableUndoRegistration];
        } else {
            NSLog(@"Something went wrong opening your document.");
        }
        
        /*if ([[NSFileManager defaultManager] fileExistsAtPath:[weAllPayURL path]]) {
            [weAllPayStoreDocument openWithCompletionHandler:^(BOOL success){
                if (success) {
                    // The document is ready to use.
                    [[weAllPayStoreDocument managedObjectContext] setUndoManager:[[NSUndoManager alloc] init]];
                    [[[weAllPayStoreDocument managedObjectContext] undoManager] disableUndoRegistration];
                } else {
                    // The document is is not ready to use.
                    NSLog(@"Couldn't open storage file at %@", weAllPayURL);
                }
            }];
        }
        else {
            // If file doesn't exist. Create it.
            [weAllPayStoreDocument saveToURL:weAllPayURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
                if (success) {
                    // The document is ready to use.
                    [[weAllPayStoreDocument managedObjectContext] setUndoManager:[[NSUndoManager alloc] init]];
                    [[[weAllPayStoreDocument managedObjectContext] undoManager] disableUndoRegistration];
                } else {
                    // The document is not ready to use.
                    NSLog(@"Couldn't create storage file at %@", weAllPayURL);
                }
            }];
        }*/
        stillNeedsInit = 0;
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self defaultStore];
}

@end
