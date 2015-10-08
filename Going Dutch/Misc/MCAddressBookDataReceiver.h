//
//  MCAddressBookDataReceiver.h
//  We all pay
//
//  Created by Mark Cornelisse on 28-05-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import Foundation;
@import AddressBookUI;
@import AddressBook;

#import "MCTonightsBillTransfer.h"

@class MCPerson;
@class MCSharedBill;

@protocol MCAddressBookReceiverDelegate <NSObject, MCTonightsBillTransfer>

- (BOOL) isPersonAlreadyPresent:(MCPerson *)newPerson;
- (MCPerson *)personRecordToUse;
- (void) receiveANewPersonFromAddressBook:(MCPerson *)newPerson;

@end

@interface MCAddressBookDataReceiver : NSObject <ABPeoplePickerNavigationControllerDelegate>
{
    __weak UIViewController *viewController;    
}

@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) MCPerson *thisPerson;
@property (nonatomic, strong) MCSharedBill *tonightsBill;

// Should be accessed only from the background queue.
@property (nonatomic, strong) MCPerson *writableThisPerson;
@property (nonatomic, strong) MCSharedBill *writableTonightsBill;

- (id)initWithDelegate:(id)delegateUsedOnInit;
- (id)initWithViewController:(UIViewController *)newViewController andDelegate:(id)newDelegate;

@end
