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

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *selectEmailAddressButton;
@property (weak, nonatomic) IBOutlet UIImageView *pictureView;

@property (nonatomic) BOOL isSelectEmail;
@property (nonatomic) BOOL didSomethingChange;
@property (nonatomic) BOOL isNew;
@property (nonatomic) MCIsEditing isEditingEmailField;
@property (nonatomic) MCCancelButtonPressed mainCancelPressed;

@property (strong, nonatomic) MCPerson *thisPerson;
@property (strong, nonatomic) MCSharedBill *tonightsBill;

// Only accessible in the background thread.
@property (strong, nonatomic) MCSharedBill *writableTonightsBill;
@property (strong, nonatomic) MCPerson *writableThisPerson;

@end
