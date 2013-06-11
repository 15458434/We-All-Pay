//
//  MCAddressBookDataReceiver.h
//  We all pay
//
//  Created by Mark Cornelisse on 28-05-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>

@class MCPerson;

@protocol MCAddressBookReceiverDelegate <NSObject>

- (void) receiveANewPersonFromAddressBook:(MCPerson *)newPerson;

@end

@interface MCAddressBookDataReceiver : NSObject <ABPeoplePickerNavigationControllerDelegate>
{
    __weak UIViewController *viewController;    
}

@property (nonatomic, strong) id delegate;
@property (nonatomic, copy) MCPerson *editedPerson;

- (id)initWithDelegate:(id)delegateUsedOnInit;
- (id)initWithViewController:(UIViewController *)newViewController andDelegate:(id)newDelegate;

@end
