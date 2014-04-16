//
//  MCPaymentTableViewController_iPad.h
//  We all pay
//
//  Created by Mark Cornelisse on 06-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCTonightsBillTransfer.h"
#import "MCThisPaymentProtocol.h"
#import "MCDismissMeBlockProtocol.h"

@class MCPayment;
@class MCSharedBill;

typedef NS_ENUM(BOOL, MCDidSomethingChange) {
    MCNothingHasChanged,
    MCSomethingHasChanged
};

@interface MCPaymentTableViewController_iPad : UITableViewController <MCTonightsBillPut, MCThisPaymentProtocol, MCDismissMeBlockProtocol, UITextFieldDelegate, UIPopoverControllerDelegate>
{
    __weak IBOutlet UILabel *payerLabel;
    __weak IBOutlet UITextField *itemField;
    __weak IBOutlet UITextField *paidField;
    __weak IBOutlet UIButton *selectButton;
    
    MCDidSomethingChange _didSomethingChange;
}

@property (weak, nonatomic) IBOutlet UIImageView *payerPicture;

@property (strong, nonatomic) MCPayment *thisPayment;
@property (strong, nonatomic) MCSharedBill *tonightsBill;
@property (strong, nonatomic) void (^dismissMe)();

- (void) reloadPayerLabel;

@end
