//
//  MCPersonViewController_iPadTableViewController.h
//  We all pay
//
//  Created by Mark Cornelisse on 03-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCThisPersonProtocol.h"
#import "MCTonightsBillTransfer.h"

@class MCPerson;
@class MCSharedBill;

@interface MCPersonTableViewController_iPad : UITableViewController <UITextFieldDelegate, MCThisPersonProtocol, MCTonightsBillPut>
{
    __weak IBOutlet UIImageView *pictureView;
    __weak IBOutlet UITextField *firstNameField;
    __weak IBOutlet UITextField *lastNameField;
    __weak IBOutlet UITextField *emailField;
    
    UIPickerView *emailSelectionFromAddressBookPickerView;
    BOOL isSelectEmail;
    
    BOOL didSomethingChange;
}
@property (strong, nonatomic) MCPerson *thisPerson;
@property (strong, nonatomic) MCSharedBill *tonightsBill;

@end
