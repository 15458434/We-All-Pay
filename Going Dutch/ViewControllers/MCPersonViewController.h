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

@interface MCPersonViewController : UIViewController <UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    __weak IBOutlet UITextField *nameField;
    __weak IBOutlet UITextField *emailField;
    
    MCPerson *thisPerson;
    UIPickerView *emailSelectionFromAddressBookPickerView;
}

- (id)initWithPerson:(MCPerson *)person;


@end
