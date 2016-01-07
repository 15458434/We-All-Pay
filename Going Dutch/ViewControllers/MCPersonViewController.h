//
//  MCPersonViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 31-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import CoreData;
@import AddressBookUI;

#import "MCAddressBookDataReceiver.h"

#import "MCTonightsBillTransfer.h"
#import "MCThisPersonProtocol.h"

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

@interface MCPersonViewController : UITableViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MCAddressBookReceiverDelegate, MCTonightsBillTransfer, MCThisPersonProtocol>

@property (weak, nonatomic) IBOutlet UIImageView *pictureView;

@property (nonatomic, weak) id changeFlagDelegate;

// Only accessible on the mainThread.
@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, strong) MCPerson *thisPerson;

// Only accessible on the background thread.
@property (nonatomic, strong) MCSharedBill *writableTonightsBill;
@property (nonatomic, strong) MCPerson *writableThisPerson;

- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)selectEmailAddressPressed:(id)sender;

//- (void)writableThisPersonIsCreated:(NSNotification *)notification;
- (void)writableTonightsBillIsCreated:(NSNotification *)notification;

@end
