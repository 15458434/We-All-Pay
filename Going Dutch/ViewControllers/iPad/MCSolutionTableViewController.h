//
//  MCSolutionTableViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 11-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import MessageUI;

#import "MCTonightsBillTransfer.h"
#import "MCDismissMeBlockProtocol.h"

@class MCSharedBill;
@class MCTableEmptyMessage;

@interface MCSolutionTableViewController : UITableViewController <MCTonightsBillTransfer>

@property (strong, nonatomic) MFMailComposeViewController *mailController;
@property (strong, nonatomic) NSArray *peoplePresent;
@property (strong, nonatomic) MCSharedBill *tonightsBill;
@property (strong, nonatomic) MCSharedBill *writableTonightsBill;

- (void)openMailView:(id)sender;

- (void)updateEvent:(MCSharedBill *)event;

@end
