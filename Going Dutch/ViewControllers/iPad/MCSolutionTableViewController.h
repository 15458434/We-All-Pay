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
@class MCTableEmptyMessage_iPad;

@interface MCSolutionTableViewController : UITableViewController <MFMailComposeViewControllerDelegate, MCTonightsBillTransfer, MCDismissMeBlockProtocol>
{
    NSArray *_peoplePresent;
    
    MFMailComposeViewController *mailController;
}

@property (strong, nonatomic) MCSharedBill *tonightsBill;
@property (strong, nonatomic) MCSharedBill *writableTonightsBill;
@property (strong, nonatomic) void (^dismissMe)();

@end
