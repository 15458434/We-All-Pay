//
//  MCiScreenTableViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 15-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import MessageUI;
@import Social;
@import StoreKit;

@interface MCiScreenTableViewController : UITableViewController <MFMailComposeViewControllerDelegate>
{
    __weak IBOutlet UILabel *versionLabel;
    
    NSUInteger numberOfRowsInSection0;
}

- (IBAction)mainCancelButtonPressed:(id)sender;
- (IBAction)tweetAboutUsPressed:(id)sender;

@end
