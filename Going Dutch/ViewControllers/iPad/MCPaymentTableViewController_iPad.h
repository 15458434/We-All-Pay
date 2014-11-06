//
//  MCPaymentTableViewController_iPad.h
//  We all pay
//
//  Created by Mark Cornelisse on 06-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "MCTonightsBillTransfer.h"
#import "MCThisPaymentProtocol.h"
#import "MCDismissMeBlockProtocol.h"
#import "MCDismissKeyboardProtocol.h"

@class MCPayment;
@class MCSharedBill;

typedef NS_ENUM(BOOL, MCDidSomethingChange) {
    MCNothingHasChanged,
    MCSomethingHasChanged
};

typedef NS_ENUM(BOOL, MCIsNew) {
    isNew,
    isNotNew
};

typedef NS_ENUM(BOOL, MCCancelButtonPressed) {
    cancelIsNotPressed,
    cancelIsPressed
};

@interface MCPaymentTableViewController_iPad : UITableViewController <MCTonightsBillTransfer, MCThisPaymentProtocol, MCDismissMeBlockProtocol, MCDismissKeyboardProtocol, UITextFieldDelegate, UIPopoverControllerDelegate, NSFetchedResultsControllerDelegate>
{
    __weak IBOutlet UITextField *itemField;
    __weak IBOutlet UITextField *paidField;
    
    MCDidSomethingChange _didSomethingChange;
    MCIsNew _isNew;
    MCCancelButtonPressed _mainCancelPressed;
    
    NSFetchedResultsController *_dataController;
    NSArray *_paymentPresenceArray;
}

@property (strong, nonatomic) MCPayment *thisPayment;
@property (strong, nonatomic) MCSharedBill *tonightsBill;
@property (strong, nonatomic) MCSharedBill *writableTonightsBill;
@property (strong, nonatomic) void (^dismissMe)();

- (void) reloadPayerLabel;

@end
