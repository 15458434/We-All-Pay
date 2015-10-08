//
//  MCPaymentViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 29-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import UIKit;
@import CoreData;
@import NotificationCenter;

#import "MCThisPaymentProtocol.h"
#import "MCPathComponentsToOpenProtocol.h"

@class MCPayment;
@class MCSharedBill;
@class MCPerson;
@class MCPaymentViewController;
@class MCTwoLabelsTitleView;

typedef NS_ENUM(NSUInteger, MCMoneyValueFieldDismissStatus) {
    cancelIsPressed,
    doneIsPressed,
    otherTextFieldSelected,
    backgroundTapped,
    currencySelectionTapped
};

@protocol MCPaymentViewControllerDelegate <NSObject>

- (void)removePayment:(MCPayment *)payment fromPaymentViewController:(MCPaymentViewController *)pvc;

@end

@interface MCPaymentViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate, MCThisPaymentProtocol, MCPathComponentsToOpenProtocol>
{
    UIBarButtonItem *theDoneButton;
    UIBarButtonItem *cancelChangesForEntirePaymentButton;
    MCTwoLabelsTitleView *twoLabelTitleView;
    
    __weak IBOutlet UITextField *payerNameField;
    MCPerson *payerViewPerson;
    __weak IBOutlet UITextField *itemView;
    __weak IBOutlet UITextField *paidView;
    NSNumber *paidViewNumber;
    
    UIPickerView *personPickerView;
    NSArray *listOfPeople;
    BOOL peoplePickerCancelled;
    MCMoneyValueFieldDismissStatus kindOfPaidFieldDismiss;
    
    NSArray *_paymentPresenceArray;
    NSFetchedResultsController *_dataController;
}

@property (nonatomic, strong) MCPayment *thisPayment;
@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, readonly) BOOL didSomethingChange;
@property (nonatomic, readonly) BOOL isNew;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSArray *pathComponentsToOpen;

- (IBAction)mainCancelButtonPressed:(id)sender;
- (IBAction)mainDoneButtonPressed:(id)sender;

- (id)initWithExistingPayment:(MCPayment *)thePayment fromBill:(MCSharedBill *)bill;

@end
