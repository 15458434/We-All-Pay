//
//  MCPersonViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 31-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MCAddressBookDataReceiver.h"

@class MCPerson;
@class MCSharedBill;
@class MCTwoLabelsTitleView;

@protocol MCPersonViewChangeDelegate <NSObject>

- (void)sendDidSomethingChange:(BOOL)value;

@end

@interface MCPersonViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MCAddressBookReceiverDelegate>
{
    __weak IBOutlet UIImageView *pictureView;
    __weak IBOutlet UITextField *firstNameField;
    __weak IBOutlet UITextField *lastNameField;
    __weak IBOutlet UITextField *emailField;
    __weak IBOutlet UILabel *totalSumSpendLabel;
    MCTwoLabelsTitleView *twoLabelTitleView;
    UIBarButtonItem *addressBookButton;
    
    MCPerson *thisPerson;
    UIPickerView *emailSelectionFromAddressBookPickerView;
    
    MCAddressBookDataReceiver *personReceiver;
    
    BOOL didSomethingChange;
    BOOL isNew;
    BOOL thisPersonHasPaidSomething;
}

@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, weak) id changeFlagDelegate;
@property (nonatomic) BOOL isNew;

- (id)initWithPerson:(MCPerson *)person;


@end
