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

@interface MCPaymentViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
{
    MCPayment *thisPayment;
    MCSharedBill *tonightsBill;
    BOOL withANewPayment;
    
    __weak IBOutlet UITextField *payerView;
    MCPerson *payerViewPerson;
    __weak IBOutlet UITextField *placeView;
    __weak IBOutlet UITextField *paidView;
    NSNumber *paidViewNumber;
    __weak IBOutlet UILabel *dateAndTimeLabel;
    
    UIPickerView *personPickerView;
}

@property (nonatomic, strong) MCPayment *thisPayment;
@property (nonatomic, readonly) BOOL didSomethingChange;

- (id)initWithExistingPayment:(MCPayment *)thePayment fromBill:(MCSharedBill *)bill;

@end
