//
//  UIViewController+WeAllPayStore.m
//  We all pay
//
//  Created by Mark Cornelisse on 11/08/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "UIViewController+WeAllPayStore.h"
#import "We_all_pay-Swift.h"

@implementation UIViewController (WeAllPayStore)

- (void)startRespondingToStoreChangeNotifications
{
    NSManagedObjectContext *mainQueueContext = [[WeAllPayStoreController defaultStore] viewContext];
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self selector:@selector(storeWillSave:) name:NSManagedObjectContextWillSaveNotification object:mainQueueContext];
    [dc addObserver:self selector:@selector(storeDidSave:) name:NSManagedObjectContextDidSaveNotification object:mainQueueContext];
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
