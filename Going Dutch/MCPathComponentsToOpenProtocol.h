//
//  MCPathComponentsToOpenProtocol.h
//  We all pay
//
//  Created by Mark Cornelisse on 30/12/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Foundation;

@protocol MCPathComponentsToOpenProtocol <NSObject>

- (void)setPathComponentsToOpen:(NSArray *)pathComponentsToOpen;
- (NSArray *)pathComponentsToOpen;

@end