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
    NSManagedObjectContext *backgroundSaveContext = [[MCWeAllPayStoreController defaultStore] backgroundThreadContext];
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self selector:@selector(storeWillChange:) name:NSManagedObjectContextWillSaveNotification object:backgroundSaveContext];
    [dc addObserver:self selector:@selector(storeDidChange:) name:NSManagedObjectContextDidSaveNotification object:backgroundSaveContext];
    [dc addObserver:self selector:@selector(storeWillBeSwapped:) name:NSPersistentStoreCoordinatorStoresWillChangeNotification object:[[MCWeAllPayStoreController defaultStore] persistentStoreCoordinator]];
    [dc addObserver:self selector:@selector(storeDidSwap:) name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:[[MCWeAllPayStoreController defaultStore] persistentStoreCoordinator]];
    [dc addObserver:self selector:@selector(storedidUpdateFromUbiquitousContainer:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:[[MCWeAllPayStoreController defaultStore] persistentStoreCoordinator]];
}

- (void)stopRespondingToStorechangeNotifications
{
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc removeObserver:self];
}

- (void)storeWillChange:(NSNotification *)notification
{
    NSLog(@"viewControlleraddon: Store will change.");
}

- (void)storeDidChange:(NSNotification *)notification
{
    NSLog(@"viewControlleraddon: Store did change.");
}

- (void)storeWillBeSwapped:(NSNotification *)notification
{
    NSLog(@"viewControlleraddon: Store will be swapped.");
}

- (void)storeDidSwap:(NSNotification *)notification
{
    NSLog(@"viewControlleraddon: Store did swap.");
}

- (void)storedidUpdateFromUbiquitousContainer:(NSNotification *)notification
{
    NSLog(@"viewController: Store did update from Ubiquitous Container.");
}

@end
