//
//  MCPeopleViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 25-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MCPersonViewController.h"

@class MCPeople;
@class MCSharedBill;
@class MCTwoLabelsTitleView;

@interface MCEditTripViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate, MCPersonViewChangeDelegate>
{
    IBOutlet UIControl *newTripHeaderView;
    IBOutlet UITextField *tripNameField;
    UIBarButtonItem *doneButton;
    __strong IBOutlet MCTwoLabelsTitleView *twoLabelTitleView;
    
    NSFetchedResultsController *dataController;
    
    BOOL isInitAsNew;
}

@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, copy) void (^dismissblock)(void);
@property (nonatomic, copy) void (^dismissYourSelf)(void);
@property (nonatomic, readonly) BOOL didSomethingChange;

- (id)initWithBill:(MCSharedBill *)newBill isNew:(BOOL)isNew;
- (UIView *)NewTripHeaderView;

- (IBAction)changeNameOfTrip:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;

@end
