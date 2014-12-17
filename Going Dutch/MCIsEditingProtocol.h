//
//  MCIsEditingProtocol.h
//  We all pay
//
//  Created by Mark Cornelisse on 15/11/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@protocol MCIsEditingProtocol <NSObject>

- (BOOL)isChildTableViewEditing;
- (void)setIsChildTableViewEditing:(BOOL)isChildTableViewEditing;

@optional

- (void)toggleEditButton;

@end
