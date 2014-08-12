//
//  UIViewController+WeAllPayStore.h
//  We all pay
//
//  Created by Mark Cornelisse on 11/08/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (WeAllPayStore)

- (void)startRespondingToStoreChangeNotifications;
- (void)stopRespondingToStorechangeNotifications;
- (void)storeWillChange:(NSNotification *)notification;
- (void)storeDidChange:(NSNotification *)notification;
- (void)storeWillBeSwapped:(NSNotification *)notification;
- (void)storeDidSwap:(NSNotification *)notification;
- (void)storedidUpdateFromUbiquitousContainer:(NSNotification *)notification;

@end
