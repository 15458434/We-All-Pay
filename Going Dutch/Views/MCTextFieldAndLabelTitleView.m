//
//  MCTextFieldAndLabelTitleView.m
//  We all pay
//
//  Created by Mark Cornelisse on 19-05-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCTextFieldAndLabelTitleView.h"

@implementation MCTextFieldAndLabelTitleView

#pragma mark - New in this class.

- (id)delegate
{
    return [[self mainLabel] delegate];
}

- (void)setDelegate:(id)delegate
{
    [[self mainLabel] setDelegate:delegate];
}

#pragma mark - Inherited from super class.

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{

}*/

@end
