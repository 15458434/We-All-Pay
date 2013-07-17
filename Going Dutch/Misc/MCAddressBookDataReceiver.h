//
//  MCAddressBookDataReceiver.h
//  We all pay
//
//  Created by Mark Cornelisse on 28-05-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>

@class MCPerson;
@class MCSharedBill;

@protocol MCAddressBookReceiverDelegate <NSObject>

- (BOOL) isNewPersonFromAddressBookAlreadyPresent:(MCPerson *)newPerson;
- (void) receiveANewPersonFromAddressBook:(MCPerson *)newPerson;

@end

@interface MCAddressBookDataReceiver : NSObject <ABPeoplePickerNavigationControllerDelegate>
{
    __weak UIViewController *viewController;    
}

@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) MCPerson *thisPerson;
@property (nonatomic, strong) MCSharedBill *tonightsBill;

- (id)initWithDelegate:(id)delegateUsedOnInit;
- (id)initWithViewController:(UIViewController *)newViewController andDelegate:(id)newDelegate;

@end
