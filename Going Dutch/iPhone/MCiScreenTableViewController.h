//
//  MCiScreenTableViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 15-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCiScreenTableViewController : UITableViewController
{
    __weak IBOutlet UILabel *versionLabel;
}

- (IBAction)mainCancelButtonPressed:(id)sender;
- (IBAction)tweetAboutUsPressed:(id)sender;


@end
