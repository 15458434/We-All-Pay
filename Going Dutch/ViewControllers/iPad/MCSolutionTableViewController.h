//
//  MCSolutionTableViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 11-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "MCTonightsBillTransfer.h"
#import "MCDismissMeBlockProtocol.h"

@class MCSharedBill;

@interface MCSolutionTableViewController : UITableViewController <MFMailComposeViewControllerDelegate, MCTonightsBillPut, MCDismissMeBlockProtocol>
{
    NSArray *_solution;
    
    MFMailComposeViewController *mailController;
}

@property (strong, nonatomic) MCSharedBill *tonightsBill;
@property (strong, nonatomic) void (^dismissMe)();

@end
