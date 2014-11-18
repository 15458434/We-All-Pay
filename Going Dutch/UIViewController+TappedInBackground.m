//
//  UIViewcontroller+TappedInBackground.m
//  We all pay
//
//  Created by Mark Cornelisse on 18/11/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "UIViewController+TappedInBackground.h"
#import "UIView+MCAddons.h"

@implementation UIViewController (TappedInBackground)

- (void)startResigningFirstResponderOnBackgroundTap
{
    // Make sure a tap in the background dimisses the keyboard as well.
    UITapGestureRecognizer *thatTickles = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedInTheBackground:)];
    [thatTickles setCancelsTouchesInView:NO];
    [[self view] addGestureRecognizer:thatTickles];
}

- (void) tappedInTheBackground:(id)sender
{
    [[[self view] getFirstResponder] resignFirstResponder];
}

@end
