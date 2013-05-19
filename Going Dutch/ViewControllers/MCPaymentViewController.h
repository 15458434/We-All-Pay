//
//  MCPaymentViewController.h
//  Going Dutch
//
//  Created by Mark Cornelisse on 29-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCPayment;
@class MCSharedBill;
@class MCPerson;
@class MCPaymentViewController;
@class MCTwoLabelsTitleView;

@protocol MCPaymentViewControllerDelegate <NSObject>

- (void)removePayment:(MCPayment *)payment fromPaymentViewController:(MCPaymentViewController *)pvc;

@end

@interface MCPaymentViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
{
    UIBarButtonItem *doneButton;
    UIBarButtonItem *cancelChangesForEntirePaymentButton;
    MCTwoLabelsTitleView *twoLabelTitleView;
    
    __weak IBOutlet UITextField *payerView;
    MCPerson *payerViewPerson;
    __weak IBOutlet UITextField *placeView;
    __weak IBOutlet UITextField *paidView;
    NSNumber *paidViewNumber;
    __weak IBOutlet UILabel *dateAndTimeLabel;
    
    UIPickerView *personPickerView;
}

@property (nonatomic, strong) MCPayment *thisPayment;
@property (nonatomic, readonly) MCSharedBill *tonightsBill;
@property (nonatomic, readonly) BOOL didSomethingChange;
@property (nonatomic, readonly) BOOL isNew;
@property (nonatomic, weak) id delegate;

- (id)initWithExistingPayment:(MCPayment *)thePayment fromBill:(MCSharedBill *)bill;

@end
