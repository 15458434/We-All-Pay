//
//  UIViewController+WeAllPayStore.m
//  We all pay
//
//  Created by Mark Cornelisse on 11/08/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "UIViewController+WeAllPayStore.h"
#import "MCWeAllPayStoreController.h"

@implementation UIViewController (WeAllPayStore)

- (void)startRespondingToStoreChangeNotifications
{
    NSManagedObjectContext *mainQueueContext = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
    NSManagedObjectContext *backgroundSaveContext = [[MCWeAllPayStoreController defaultStore] backgroundThreadContext];
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self selector:@selector(storeWillSave:) name:NSManagedObjectContextWillSaveNotification object:mainQueueContext];
    [dc addObserver:self selector:@selector(storeWillSave:) name:NSManagedObjectContextWillSaveNotification object:backgroundSaveContext];
    [dc addObserver:self selector:@selector(storeDidSave:) name:NSManagedObjectContextDidSaveNotification object:mainQueueContext];
    [dc addObserver:self selector:@selector(storeDidSave:) name:NSManagedObjectContextDidSaveNotification object:backgroundSaveContext];
}

- (void)stopRespondingToStorechangeNotifications
{
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc removeObserver:self];
}

- (void)storeWillSave:(NSNotification *)notification
{
#ifdef DEBUG
    NSLog(@"%@addon: Store will save.", self);
#endif
}

- (void)storeDidSave:(NSNotification *)notification
{
#ifdef DEBUG
    NSLog(@"%@addon: Store did save.", self);
#endif
}

@end
