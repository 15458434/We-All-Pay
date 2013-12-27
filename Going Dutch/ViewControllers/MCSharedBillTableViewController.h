//
//  MCSharedBillTableViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>

@class MCSharedBill;
@class MCAllTripsTableViewController;
@class MCTwoLabelsTitleView;
@class MCTextFieldAndLabelTitleView;

@interface MCSharedBillTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
    __strong IBOutlet MCTwoLabelsTitleView *twoLabelTitleView;
    
    NSFetchedResultsController *dataController;
    
    UIBarButtonItem *mailButton;
    UIBarButtonItem *returnPaymentButton;
}

//- (id)initWithSharedBill:(MCSharedBill *)tBill;


- (IBAction)mailButtonPressed:(id)sender;

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, readonly) BOOL didSomethingChange;

@end
