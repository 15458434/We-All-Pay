//
//  MCPaymentViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 29-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "MCCancelDoneViewController.h"

#import "MCThisPaymentProtocol.h"

@class MCPayment;
@class MCSharedBill;
@class MCPerson;
@class MCPaymentViewController;
@class MCTwoLabelsTitleView;

typedef NS_ENUM(NSUInteger, MCMoneyValueFieldDismissStatus) {
    cancelIsPressed,
    doneIsPressed,
    otherTextFieldSelected,
    backgroundTapped
};

@protocol MCPaymentViewControllerDelegate <NSObject>

- (void)removePayment:(MCPayment *)payment fromPaymentViewController:(MCPaymentViewController *)pvc;

@end

@interface MCPaymentViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate, MCThisPaymentProtocol>
{
    UIBarButtonItem *theDoneButton;
    UIBarButtonItem *cancelChangesForEntirePaymentButton;
    MCTwoLabelsTitleView *twoLabelTitleView;
    
    __weak IBOutlet UITextField *payerView;
    MCPerson *payerViewPerson;
    __weak IBOutlet UITextField *itemView;
    __weak IBOutlet UITextField *paidView;
    NSNumber *paidViewNumber;
//    __weak IBOutlet UILabel *dateAndTimeLabel;
    
    UIPickerView *personPickerView;
    NSArray *listOfPeople;
    BOOL peoplePickerCancelled;
    MCMoneyValueFieldDismissStatus kindOfPaidFieldDismiss;
    
    NSArray *_paymentPresenceArray;
    NSFetchedResultsController *_dataController;
}

@property (weak, nonatomic) IBOutlet UIImageView *payerPicture;
@property (nonatomic, strong) MCPayment *thisPayment;
@property (nonatomic, strong) MCSharedBill *tonightsBill;
@property (nonatomic, readonly) BOOL didSomethingChange;
@property (nonatomic, readonly) BOOL isNew;
@property (nonatomic, weak) id delegate;

- (IBAction)mainCancelButtonPressed:(id)sender;
- (IBAction)mainDoneButtonPressed:(id)sender;

- (id)initWithExistingPayment:(MCPayment *)thePayment fromBill:(MCSharedBill *)bill;

@end
