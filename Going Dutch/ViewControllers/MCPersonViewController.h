//
//  MCPersonViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 31-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@class MCPerson;
@class MCSharedBill;

@interface MCPersonViewController : UIViewController <UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    __weak IBOutlet UIImageView *pictureView;
    __weak IBOutlet UITextField *firstNameField;
    __weak IBOutlet UITextField *lastNameField;
    __weak IBOutlet UITextField *emailField;
    __weak IBOutlet UILabel *totalSumSpendLabel;
    
    MCPerson *thisPerson;
    UIPickerView *emailSelectionFromAddressBookPickerView;
}

@property (nonatomic, strong) MCSharedBill *tonightsBill;

- (id)initWithPerson:(MCPerson *)person;


@end
