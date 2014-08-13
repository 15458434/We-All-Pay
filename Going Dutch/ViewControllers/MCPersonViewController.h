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
#import "MCTonightsBillTransfer.h"

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

@interface MCPersonViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MCAddressBookReceiverDelegate, MCTonightsBillTransfer>
{
    __weak IBOutlet UITextField *firstNameField;
    __weak IBOutlet UITextField *lastNameField;
    __weak IBOutlet UITextField *emailField;
    __weak IBOutlet UIButton *selectEmailAddressButton;
    
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
    BOOL mainCancelPressed;
    NSUInteger emailEditFieldStatus;
}

@property (weak, nonatomic) IBOutlet UIImageView *pictureView;

@property (nonatomic, weak) id changeFlagDelegate;
@property (nonatomic) BOOL isNew;

// Only accessible on the mainThread.
@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, strong) MCPerson *thisPerson;

// Only accessible on the background thread.
@property (nonatomic, strong) MCSharedBill *writableTonightsBill;
@property (nonatomic, strong) MCPerson *writableThisPerson;

- (id)initWithPerson:(MCPerson *)person;

- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)selectEmailAddressPressed:(id)sender;

//- (void)writableThisPersonIsCreated:(NSNotification *)notification;
- (void)writableTonightsBillIsCreated:(NSNotification *)notification;

@end
