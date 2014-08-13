//
//  MCPersonViewController_iPadTableViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 03-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import UIKit;

#import "MCThisPersonProtocol.h"
#import "MCTonightsBillTransfer.h"

@class MCPerson;
@class MCSharedBill;

typedef NS_ENUM(BOOL, MCIsEditing) {
    isNotEditing,
    isEditing
};

typedef NS_ENUM(BOOL, MCCancelButtonPressed) {
    cancelIsNotPressed,
    cancelIsPressed
};

@interface MCPersonTableViewController_iPad : UITableViewController <UITextFieldDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate, MCThisPersonProtocol, MCTonightsBillTransfer>
{
    //__weak IBOutlet UIImageView *_pictureView;
    __weak IBOutlet UITextField *firstNameField;
    __weak IBOutlet UITextField *lastNameField;
    __weak IBOutlet UITextField *emailField;
    __weak IBOutlet UIButton *selectEmailAddressButton;
    
    UIPickerView *emailSelectionFromAddressBookPickerView;
    BOOL isSelectEmail;
    
    BOOL didSomethingChange;
    BOOL isNew;
    MCIsEditing isEditingEmailField;
    MCCancelButtonPressed mainCancelPressed;
}

@property (weak, nonatomic) IBOutlet UIImageView *pictureView;

@property (strong, nonatomic) MCPerson *thisPerson;
@property (strong, nonatomic) MCSharedBill *tonightsBill;

// Only accessible in the background thread.
@property (strong, nonatomic) MCSharedBill *writableTonightsBill;
@property (strong, nonatomic) MCPerson *writableThisPerson;

@end
