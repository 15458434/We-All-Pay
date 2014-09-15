//
//  MCSharedBillViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 02-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBillViewController_iPad.h"

#import "UIView+MCAddons.h"

#import "MCPerson+addons.h"
#import "MCSharedBill+addons.h"
#import "MCWeAllPayStoreController.h"

#import "MCTools.h"
#import "MCDismissMeBlockProtocol.h"

@interface MCSharedBillViewController_iPad ()

@end

@implementation MCSharedBillViewController_iPad

#pragma mark - Actions

- (IBAction)editButtonPressed:(id)sender
{
    static BOOL isEditingMode = NO;
    NSArray *myKids = [self childViewControllers];
    for (id kid in myKids) {
        if ([kid respondsToSelector:@selector(setEditing:)]) {
            if (isEditingMode) {
                [kid setEditing:NO];
            } else {
                [kid setEditing:YES];
            }
        }
    }
    isEditingMode = !isEditingMode;
    if (isEditingMode) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editButtonPressed:)];
        [[self navigationItem] setRightBarButtonItem:doneButton];
    } else {
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed:)];
        [[self navigationItem] setRightBarButtonItem:editButton];
    }
}

- (IBAction)addressBookButtonPressed:(id)sender
{
    // TODO: This can be done without the Switch case.
    switch (ABAddressBookGetAuthorizationStatus())
    {
            // Update our UI if the user has granted access to their Contacts
        case  kABAuthorizationStatusAuthorized:
            [self openPeoplePicker];
            break;
            // Prompt the user for access to Contacts if there is no definitive answer
        case  kABAuthorizationStatusNotDetermined :
            // Display a message if the user has denied or restricted access to Contacts
        case  kABAuthorizationStatusDenied:
        case  kABAuthorizationStatusRestricted:
        {
            CFErrorRef error;
            ABAddressBookRef myAddressBook = ABAddressBookCreateWithOptions(NULL, &error);
            if (error) {
                NSLog(@"Something went wrong opening myAddressBook.");
            }
            
            typeof(self) __weak weakSelf = self;
            // Popup for user will only appear once.
            ABAddressBookRequestAccessWithCompletion(myAddressBook, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf openPeoplePicker];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf showContactsDisabledMessage];
                    });
                }
            });
        }
            
            break;
        default:
            break;
    }
}


#pragma mark - New in this class

- (void)openPeoplePicker
{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    if (!personReceiver) {
        personReceiver = [[MCAddressBookDataReceiver alloc] initWithViewController:self andDelegate:self];
        [personReceiver setTonightsBill:_tonightsBill];
    }
    [peoplePicker setPeoplePickerDelegate:personReceiver];
    [peoplePicker setEdgesForExtendedLayout:UIRectEdgeNone];
    //    [[peoplePicker viewControllers][0] setEdgesForExtendedLayout:UIRectEdgeNone];
    [peoplePicker setModalPresentationStyle:UIModalPresentationFormSheet];
    
    [[self navigationController] presentViewController:peoplePicker animated:YES completion:^{
        //        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        //        [tracker set:kGAIScreenName value:@"Peoplepicker_iPad"];
        //        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    }];
}

- (void)showContactsDisabledMessage
{
    NSString *title = NSLocalizedString(@"CONTACTS_DISABLED_TITLE", @"Contacts disabled");
    NSString *message = NSLocalizedString(@"CONTACTS_DISABLED_MESSAGE", @"Access to Contacts can be enable in Settings->We All Pay->Privacy");
    NSString *cancelButtonTitle = NSLocalizedString(@"OK", @"Ok");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Inherited From super

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [MCTools setAdBannerIfNotPaid:YES forViewController:self];
    
    [[self navigationController] setToolbarHidden:YES animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [tripNameField setText:[_tonightsBill tripName]];
    
    // Set the color of the backButton.
    UIColor *backButtonColor = [MCColors getButtonColor];
    [[[self navigationController] navigationBar] setTintColor:backButtonColor];
    [[[self navigationItem] rightBarButtonItem] setTintColor:backButtonColor];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (!parent) {
        // Parent is null when back button is pressed in navigationbar
        
        UIView *firstResponder = [[self view] getFirstResponder];
        if (firstResponder) {
            [firstResponder resignFirstResponder];
        }
        [_tonightsBill deleteIfStillNew];
        [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MCAddressBookReceiverDelegate

- (MCPerson *)personRecordToUse
{
    return nil;
}

- (void)receiveANewPersonFromAddressBook:(MCPerson *)newPerson
{
    // Not implemented.
}

- (BOOL)isPersonAlreadyPresent:(MCPerson *)newPerson
{
    // Function is not used at the moment.
    return NO;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == tripNameField) {
        [_tonightsBill setTripName:[tripNameField text]];
    }
}

#pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // When newPerson segue is used add a person to tonightsBill.
    if ([[segue identifier] isEqualToString:@"newPerson"]) {
        id destination = [[segue destinationViewController] viewControllers][0];
        if ([destination conformsToProtocol:@protocol(MCTonightsBillTransfer)]) {
            [destination setTonightsBill:_tonightsBill];
        }
//        if ([destination conformsToProtocol:@protocol(MCDismissMeBlockProtocol)]) {
//            __weak MCSharedBillViewController_iPad *weakSelf = self;
//            [destination setDismissMe:^{
//                MCSharedBillViewController_iPad *strongSelf = weakSelf;
//                if (strongSelf) {
////                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
////                    [tracker set:kGAIScreenName value:@"MCSharedBillMainViewController_iPad"];
////                    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
//                }
//            }];
//        }
    }
    
    // When newPerson segue is used to add a new payment to tonightsbill.
    if ([[segue identifier] isEqualToString:@"newPayment"]) {
        id destination = [[segue destinationViewController] viewControllers][0];
        if ([destination conformsToProtocol:@protocol(MCTonightsBillTransfer)]) {
            [destination setTonightsBill:_tonightsBill];
        }
//        if ([destination conformsToProtocol:@protocol(MCDismissMeBlockProtocol)]) {
//            __weak MCSharedBillViewController_iPad *weakSelf = self;
//            [destination setDismissMe:^{
//                MCSharedBillViewController_iPad *strongSelf = weakSelf;
//                if (strongSelf) {
////                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
////                    [tracker set:kGAIScreenName value:@"MCSharedBillMainViewController_iPad"];
////                    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
//                }
//            }];
//        }
    }
    
    // When openSolutionView is used to go to the solution screen.
    if ([[segue identifier] isEqualToString:@"openSolutionView"]) {
        id destination = [[segue destinationViewController] viewControllers][0];
        if ([destination conformsToProtocol:@protocol(MCTonightsBillTransfer)]) {
            [destination setTonightsBill:_tonightsBill];
        }
        if ([destination conformsToProtocol:@protocol(MCDismissMeBlockProtocol)]) {
            __weak MCSharedBillViewController_iPad *weakSelf = self;
            [destination setDismissMe:^{
                MCSharedBillViewController_iPad *strongSelf = weakSelf;
                if (strongSelf) {
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
//                        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//                        [tracker set:kGAIScreenName value:@"MCSharedBillMainViewController_iPad"];
//                        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
                    }];
                }
            }];
        }
    }
}

@end
