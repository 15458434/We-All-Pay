//
//  UIViewController+WeAllPayStore.h
//  We all pay
//
//  Created by Mark Cornelisse on 11/08/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import UIKit;

@interface UIViewController (WeAllPayStore)

- (void)startRespondingToStoreChangeNotifications;
- (void)stopRespondingToStorechangeNotifications;
- (void)storeWillSave:(NSNotification *)notification;
- (void)storeDidSave:(NSNotification *)notification;

@end
