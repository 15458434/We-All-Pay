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
    [dc addObserver:self selector:@selector(storeWillBeSwapped:) name:NSPersistentStoreCoordinatorStoresWillChangeNotification object:[[MCWeAllPayStoreController defaultStore] persistentStoreCoordinator]];
    [dc addObserver:self selector:@selector(storeDidSwap:) name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:[[MCWeAllPayStoreController defaultStore] persistentStoreCoordinator]];
    [dc addObserver:self selector:@selector(storedidUpdateFromUbiquitousContainer:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:[[MCWeAllPayStoreController defaultStore] persistentStoreCoordinator]];
}

- (void)stopRespondingToStorechangeNotifications
{
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc removeObserver:self];
}

- (void)storeWillSave:(NSNotification *)notification
{
    NSLog(@"%@addon: Store will save.", self);
}

- (void)storeDidSave:(NSNotification *)notification
{
    NSLog(@"%@addon: Store did save.", self);
}

- (void)storeWillBeSwapped:(NSNotification *)notification
{
    NSLog(@"%@addon: Store will be swapped.", self);
    // Deactivate UI
}

- (void)storeDidSwap:(NSNotification *)notification
{
    NSLog(@"%@addon: Store did swap.", self);
    // Reactivate UI and refetch.
}

- (void)storedidUpdateFromUbiquitousContainer:(NSNotification *)notification
{
    NSLog(@"%@addon: Store did update from Ubiquitous Container.", self);
}

@end
