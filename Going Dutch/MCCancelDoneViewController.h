//
//  MCCancelDoneViewController.h
//  My bug and feature project
//
//  Created by Mark Cornelisse on 25-10-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import UIKit;

@interface MCCancelDoneViewController : UIViewController
{
    UIBarButtonItem *mainCancelButton;
    UIBarButtonItem *mainDoneButton;
    
    NSArray *listOfInputs;
}

@property (nonatomic) BOOL willShowButtons;
@property (nonatomic) BOOL switchInputField;

- (UITextField *)returnNextUITextField:(UITextField *)currentInput;
- (UITextField *)selectNextUITextField:(UITextField *)currentInput;

@end
