//
//  MCPeopleViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 25-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <CoreData/CoreData.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MCPersonViewController.h"

@class MCPeople;
@class MCSharedBill;
@class MCTwoLabelsTitleView;
@class MCTableEmptyMessage;

@interface MCEditTripViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate, MCPersonViewChangeDelegate>
{
    __weak IBOutlet UIButton *addressBookButton;    
    __weak IBOutlet UIButton *addPersonButton;
    
    IBOutlet UITextField *tripNameField;
    IBOutlet UIBarButtonItem *doneButton;
    __strong IBOutlet MCTwoLabelsTitleView *twoLabelTitleView;
    MCTableEmptyMessage *emptyMessage;
    
    NSFetchedResultsController *dataController;
    MCAddressBookDataReceiver *personReceiver;
    
    BOOL isInitAsNew;
    BOOL cancelPressed;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, copy) void (^dismissOnDone)(void);
@property (nonatomic, copy) void (^dismissOnCancel)(void);
@property (nonatomic, readonly) BOOL didSomethingChange;

- (IBAction)addressBookButton:(id)sender;
- (IBAction)addPersonButton:(id)sender;

- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end
