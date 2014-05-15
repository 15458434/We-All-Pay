//
//  MCPaymentViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 29-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCCancelDoneViewController.h"

@class MCPayment;
@class MCSharedBill;
@class MCPerson;
@class MCPaymentViewController;
@class MCTwoLabelsTitleView;


@protocol MCPaymentViewControllerDelegate <NSObject>

- (void)removePayment:(MCPayment *)payment fromPaymentViewController:(MCPaymentViewController *)pvc;

@end

@interface MCPaymentViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
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
    
    NSArray *_paymentPresenceArray;
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
