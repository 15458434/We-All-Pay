//
//  MCPeopleViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 25-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@class MCPeople;
@class MCSharedBill;
@class MCPersonViewController;

@interface MCCreateNewTripViewController : UITableViewController <UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate>
{
    IBOutlet UIControl *newTripHeaderView;
    IBOutlet UITextField *tripNameField;
    
    MCSharedBill *tonightsBill;
}

@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, copy) void (^dismissblock)(void);
@property (nonatomic, copy) void (^dismissYourSelf)(void);

- (id)initWithBill:(MCSharedBill *)newBill isNew:(BOOL)isNew;
- (UIView *)NewTripHeaderView;

- (IBAction)changeNameOfTrip:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;

@end
