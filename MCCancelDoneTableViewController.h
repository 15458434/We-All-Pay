//
//  MCCancelDoneViewController.h
//  My bug and feature project
//
//  Created by Mark Cornelisse on 25-10-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import UIKit;

@interface MCCancelDoneTableViewController : UITableViewController
{
    UIBarButtonItem *mainCancelButton;
    UIBarButtonItem *mainDoneButton;
}

@property (nonatomic) BOOL willShowButtons;

@end
