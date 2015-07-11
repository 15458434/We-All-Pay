//
//  MCDismissMeBlockProtocol.h
//  We all pay
//
//  Created by Mark Cornelisse on 10-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import Foundation;

@protocol MCDismissMeBlockProtocol <NSObject>

- (void)setDismissMe:(void (^)())dismissMe;

@end
