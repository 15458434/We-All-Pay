//
//  MultipleCurrencyInterface.m
//  We all pay
//
//  Created by Mark Cornelisse on 16/09/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MultipleCurrencyInterface.h"

@interface MultipleCurrencyInterface ()

@end

@implementation MultipleCurrencyInterface

#pragma mark - Actions

- (IBAction)closeWindow:(id)sender
{
    NSLog(@"Invoking close.");
    [self close];
}

#pragma mark - Inherited from super

- (instancetype)init
{
    self = [super initWithWindowNibName:@"MultipleCurrencyInterface"];
    if (self) {
        // Enter some custom code here if necessary.

    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
