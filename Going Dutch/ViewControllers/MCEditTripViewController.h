//
//  MCPeopleViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 25-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MCPersonViewController.h"

@class MCPeople;
@class MCSharedBill;

@interface MCEditTripViewController : UITableViewController <UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate, UIAlertViewDelegate, MCPersonViewChangeDelegate>
{
    IBOutlet UIControl *newTripHeaderView;
    IBOutlet UITextField *tripNameField;
    UIBarButtonItem *doneButton;
    
    MCSharedBill *tonightsBill;
    BOOL isInitAsNew;
    NSString *tripName;
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
