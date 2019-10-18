//
//  MCPersonViewController_iPadTableViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 03-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import FirebaseAnalytics;

#import "MCPersonTableViewController_iPad.h"

#import "UINavigationController+KeyboardDismiss.h"

#import "MCPerson+addons.h"
#import "MCSharedBill+addons.h"
#import "MCEmailAddress+addons.h"

#import "MCTonightsBillTransfer.h"
#import "MCDismissMeBlockProtocol.h"

#import "MCWeAllPayStoreController.h"

#import "We_all_pay-Swift.h"

typedef NS_ENUM(BOOL, MCStatus) {
    MCStatusInValid,
    MCStatusValid
};

@interface MCPersonTableViewController_iPad ()

@property (nonatomic) MCStatus emailAddressStringInTextField;

@end

@implementation MCPersonTableViewController_iPad

#pragma mark - Actions

- (IBAction)mainCancelButtonPressed:(id)sender {
    [FIRAnalytics logEventWithName:@"Main Canncel Pressed" parameters:nil];
    [self.view resignFirstResponder];
    _mainCancelPressed = cancelIsPressed;
    if ([_thisPerson.managedObjectContext.undoManager canUndo]) {
        [[MCWeAllPayStoreController defaultStore] endUndoGroupAndUndo];
    } else {
        [[MCWeAllPayStoreController defaultStore] endUndoGroup];
    }
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)mainDoneButtonPressed:(id)sender {
    [FIRAnalytics logEventWithName:@"Main Done Pressed" parameters:nil];
    [self.view resignFirstResponder];
    if ([MCTools isStringAnEmailAddress:_emailField.text]) {
        [self dismissFromDone];
        [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
    } else {
        NSString *title = NSLocalizedString(@"INVALID_EMAIL_ADDRESS", "Invalid email address");
        NSString *message = NSLocalizedString(@"INVALID_EMAIL_ADDRESS_MESSAGE", @"The email address you provided doesn't appear to be an email address. This might cause improper behavior. Are you sure you want to continu?");
        NSString *yesTitle = NSLocalizedString(@"YES", @"yes");
        NSString *noTitle = NSLocalizedString(@"NO", @"no");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:noTitle style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:yesTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissFromDone];
            [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)selectEmailAddressButtonPressed:(id)sender {
    [FIRAnalytics logEventWithName:@"Select email address pressed" parameters:nil];
}

- (IBAction)backgroundTappedToDismissKeyboard:(id)sender {
    [FIRAnalytics logEventWithName:@"BackgroundTapped to dismiss keyboard" parameters:nil];
    [self dismissTheKeyboard];
}

#pragma mark - New in this class

- (void)dismissFromDone {
    NSDate *now = NSDate.date;
    _tonightsBill.dateModified = now;
    [[MCWeAllPayStoreController defaultStore] endUndoGroupAndProcess];
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)tappedInTheBackground:(id)selector {
    [self dismissTheKeyboard];
}

- (void) dismissTheKeyboard {
    if ([_firstNameField isFirstResponder]) {
        [_firstNameField resignFirstResponder];
    } else if ([_lastNameField isFirstResponder]) {
        [_lastNameField resignFirstResponder];
    } else if ([_emailField isFirstResponder]) {
        [_emailField resignFirstResponder];
    }
}

#pragma mark - Inherited From Super

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _emailAddressStringInTextField = MCStatusInValid;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isEditingEmailField = isNotEditing;
    _mainCancelPressed = cancelIsNotPressed;
    [[MCWeAllPayStoreController defaultStore] beginUndoGroup];
    
    // Make sure a tap in the background dismisses the keyboard as well.
    UITapGestureRecognizer *thatTickles = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedInTheBackground:)];
    thatTickles.cancelsTouchesInView = NO;
    [[self tableView] addGestureRecognizer:thatTickles];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_thisPerson) {
        _thisPerson = [_tonightsBill addPerson];
        [_thisPerson setPictureDataFromImage:nil];
        [_thisPerson setThumbnailDataFromImage:nil];
//        didSomethingChange = YES;
        _isNew = YES;
        NSString *newHeaderTitle = NSLocalizedString(@"NEW_PERSON_HEADER", @"new person");
        self.title = newHeaderTitle;
    } else {
        _isNew = NO;
    }
    
    // If there is none or only one emailAddress the button for an email address should not be shown.
    if ([[_thisPerson emailAddress] count] < 2) {
        _selectEmailAddressButton.hidden = YES;
    } else {
        _selectEmailAddressButton.hidden = NO;
    }
    

    _firstNameField.text = _thisPerson.firstName;
    _lastNameField.text = _thisPerson.lastName;
    _emailField.text = _thisPerson.defaultEmailAddress;
    
    _pictureView.image = _thisPerson.picture;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == _firstNameField) {
        [FIRAnalytics logEventWithName:@"firstNameField didBeginEditing" parameters:nil];
    } else if (textField == _lastNameField) {
        [FIRAnalytics logEventWithName:@"lastNameField didBeginEditing" parameters:nil];
    } else if (textField == _emailField) {
        [FIRAnalytics logEventWithName:@"emailField didBeginEditing" parameters:nil];
        _isEditingEmailField = isEditing;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == _emailField) {
#ifdef DEBUG
        NSLog(@"should dismiss emailField");
#endif
        if ([MCTools isStringAnEmailAddress:[_emailField text]]) {
            _emailField.textColor = UIColor.blackColor;
            _emailAddressStringInTextField = MCStatusValid;
            return YES;
        } else {
            _emailField.textColor = UIColor.redColor;
            _emailAddressStringInTextField = MCStatusInValid;
            return NO;
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // First check is mainCancel has been pressed. In that case this will be executed after the textField has been dismissed.
    if (_mainCancelPressed == cancelIsNotPressed) {
        if (textField == _firstNameField) {
            [FIRAnalytics logEventWithName:@"firstNameField didEndEditing" parameters:nil];
            _thisPerson.firstName = textField.text;
        } else if (textField == _lastNameField) {
            [FIRAnalytics logEventWithName:@"lastNameField didEndEditing" parameters:nil];
            _thisPerson.lastName = textField.text;
        } else if (textField == _emailField) {
            [FIRAnalytics logEventWithName:@"emailField didEndEditing" parameters:nil];
            if (_isNew) {
                [_thisPerson addOneEmailAddressFromAString:[_emailField text]];
            } else {
                MCEmailAddress *defaultEmail = [_thisPerson getDefaultEmailAddressObject];
                if (!defaultEmail) {
                    [_thisPerson addOneEmailAddressFromAString:[_emailField text]];
                } else {
                    defaultEmail.emailAddress = _emailField.text;
                }
            }
            _isEditingEmailField = isNotEditing;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"openSelectEmailAddress"]) {
        __weak SelectEmailAddressTableViewController_iPad *destination = [segue destinationViewController];
        destination.thisPerson = _thisPerson;
        if ([destination conformsToProtocol:@protocol(MCDismissMeBlockProtocol)]) {
            [destination setDismissMe:^{
                [FIRAnalytics logEventWithName:@"dismiss select email address" parameters:nil];
                if (destination) {
                    [destination dismissViewControllerAnimated:YES completion:^{
                        self.emailField.text = self.thisPerson.defaultEmailAddress;
                    }];
                }
            }];
        }
    }
}

@end
