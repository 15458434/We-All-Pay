//
//  MCPersonViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 31-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <CoreData/CoreData.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MCAddressBookDataReceiver.h"

typedef enum _emailFieldEditStatus {
    MCEmailFieldEditNormal = 0,
    MCEmailFieldEditAdd = 1,
    MCEmailFieldSelectDefaultAddress = 2,
}emailFieldEditStatus;

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
    // __weak IBOutlet UILabel *totalSumSpendLabel;
    MCTwoLabelsTitleView *twoLabelTitleView;
    UIBarButtonItem *addressBookButton;
    

    UIPickerView *emailSelectionFromAddressBookPickerView;
    BOOL isSelectEmail;
    
    MCAddressBookDataReceiver *personReceiver;
    NSFetchedResultsController *dataController;
    NSUndoManager *undoManager;
    
    BOOL didSomethingChange;
    BOOL isNew;
    BOOL thisPersonHasPaidSomething;
    NSUInteger emailEditFieldStatus;
}

@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, weak) id changeFlagDelegate;
@property (nonatomic) BOOL isNew;
@property (nonatomic, strong) MCPerson *thisPerson;

- (id)initWithPerson:(MCPerson *)person;

- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)selectEmailAddressPressed:(id)sender;

@end
