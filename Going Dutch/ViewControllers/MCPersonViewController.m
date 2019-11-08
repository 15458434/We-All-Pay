//
//  MCPersonViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 31-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import FirebaseAnalytics;

#import "MCPersonViewController.h"

#import "MCWeAllPayStoreController.h"
#import "MCPerson+addons.h"
#import "MCSharedBill+addons.h"
#import "MCEmailAddress+addons.h"

#import "MCTools.h"

typedef NS_ENUM(BOOL, MCStatus) {
    MCStatusInvalid,
    MCStatusValid
};

@interface MCPersonViewController ()

@property (nonatomic, weak) IBOutlet UITextField *firstNameField;
@property (nonatomic, strong) MCNameTextInputValidator *firstNameFieldValidator;
@property (nonatomic, weak) IBOutlet UITextField *lastNameField;
@property (nonatomic, strong) MCNameTextInputValidator *familyNameFieldValidator;
@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UIButton *selectEmailAddressButton;
@property (nonatomic, strong) MCEmailTextInputProxy *emailTextInputReceiver;

@property (nonatomic, strong) MCTwoLabelsTitleView *twoLabelTitleView;
@property (nonatomic, strong) UIBarButtonItem *addressBookButton;
@property (nonatomic, strong) UIPickerView *emailSelectionFromAddressBookPickerView;
@property (nonatomic) BOOL isSelectEmail;
@property (nonatomic) NSUInteger emailEditFieldStatus;

@property (nonatomic, strong) NSFetchedResultsController *dataController;

@property (nonatomic, strong) IBOutlet MCPersonModel *model;

@property (atomic, copy) NSDate * dateModified;
@property (atomic, copy) NSString * defaultEmailAddress;
@property (atomic, copy) NSString * firstName;
@property (atomic, copy) NSString * lastName;
@property (atomic, strong) NSString * phoneNumber;
@property (atomic, copy) UIImage * picture;
@property (atomic, copy) UIImage * thumbnail;

@property (nonatomic) MCStatus emailAddressStringInTextField;

@property (nonatomic) BOOL didSomethingChange;
@property (nonatomic) BOOL thisPersonHasPaidSomething;
@property (nonatomic) BOOL mainCancelPressed;

@end

@implementation MCPersonViewController

@synthesize changeFlagDelegate;
@synthesize isNew;

- (IBAction)cancelButtonPressed:(id)sender
{
    [FIRAnalytics logEventWithName:@"Cancel button pressed" parameters:nil];
    [self.view endEditing:YES];
    [[MCWeAllPayStoreController defaultStore] endUndoGroupAndUndo];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectEmailAddressPressed:(id)sender {
    [FIRAnalytics logEventWithName:@"Select email address pressed" parameters:nil];
    // If any of the fields is first responder resign them first.
    [self.view endEditing:YES];
    
    _emailTextInputReceiver.target = MCEmailTextInputProxyTargetPicker;
    UIPickerView *inputView = [[UIPickerView alloc] init];
    inputView.delegate = _emailTextInputReceiver;
    inputView.dataSource = _emailTextInputReceiver;
    inputView.showsSelectionIndicator = YES;
    [inputView selectRow:_model.indexOfDefaultEmailAddress inComponent:0 animated:YES];
    _emailField.inputView = inputView;
    _emailField.tintColor = UIColor.clearColor;
    [_emailField becomeFirstResponder];
}

- (IBAction)doneButtonPressed:(id)sender
{
    [FIRAnalytics logEventWithName:@"Done button pressed" parameters:nil];
    [self.view endEditing:YES];
    [_thisPerson setDateModified:[NSDate date]];
    [[MCWeAllPayStoreController defaultStore] endUndoGroupAndProcess];
    [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)fillTheScreenWithInitialData
{
    // Should be execute on the mainThread.
    MCEmailAddress *emailAddress = [MCEmailAddress fetchEmailAddressFor:_thisPerson];
    [_emailField setText:[emailAddress emailAddress]];
    _pictureView.image = _thisPerson.picture;
    if ([[_thisPerson emailAddress] count] < 2) {
        [_selectEmailAddressButton setHidden:YES];
    } else {
        [_selectEmailAddressButton setHidden:NO];
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_thisPerson) {
        // A new person object will be delivered
        _thisPersonHasPaidSomething = NO;
    } else if ([_tonightsBill hasPersonPaidSomething:_thisPerson]) { // Check to see if thisPerson has paid something.
        _thisPersonHasPaidSomething = YES;
    } else {
        _thisPersonHasPaidSomething = NO;
    }
    
    _isSelectEmail = NO;
    
    __weak typeof(self) weakSelf = self;
    [_model prepareForUseWithPerson:_thisPerson andChangeHandler:^(MCPerson * _Nonnull person) {
        typeof(self) strongSelf = weakSelf;
        NSParameterAssert(strongSelf);
        if (strongSelf) {
            strongSelf.firstNameField.text = person.firstName;
            strongSelf.lastNameField.text = person.lastName;
            strongSelf.emailField.text = person.defaultEmailAddress;
            
            strongSelf.emailTextInputReceiver.target = MCEmailTextInputProxyTargetPicker;
            strongSelf.emailField.inputView = nil;
            strongSelf.emailField.tintColor = UIColor.systemBlueColor;
        }
    }];
    _firstNameFieldValidator = [[MCNameTextInputValidator alloc] initWithModel:_model andTextField:_firstNameField andConfig:MCNameTextInputValidatorConfigFirstName];
    _familyNameFieldValidator = [[MCNameTextInputValidator alloc] initWithModel:_model andTextField:_lastNameField andConfig:MCNameTextInputValidatorConfigFamilyName];
    MCEmailTextInputValidator *validator = [[MCEmailTextInputValidator alloc] initWithTextField:_emailField andModel:_model];
    MCEmailTextInputPicker *picker = [[MCEmailTextInputPicker alloc] initWithTextField:_emailField andModel:_model];
    _emailTextInputReceiver = [[MCEmailTextInputProxy alloc] initWithValidator:validator andPicker:picker andTarget:MCEmailTextInputProxyTargetValidator];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self navigationController] setToolbarHidden:YES animated:YES];
    
    if (!_twoLabelTitleView) {
        _twoLabelTitleView = [[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil][0];
        if (isNew) {
            _twoLabelTitleView.mainLabel.text = NSLocalizedString(@"NEW_PERSON_HEADER", @"Header in the personView which state new person.");
            _twoLabelTitleView.subLabel.text = NSLocalizedString(@"NEW_PERSON_SUBHEADER", @"Sub header in the personView which states add new data");
        } else {
            _twoLabelTitleView.mainLabel.text = NSLocalizedString(@"EXISTING_PERSON_HEADER", @"Header in the personView which states person");
            _twoLabelTitleView.subLabel.text = NSLocalizedString(@"EXISTING_PERSON_SUBHEADER", @"Sub header in the personView which state edit data");
        }

        self.navigationItem.titleView = _twoLabelTitleView;
    }

    if (_thisPerson) {
        [self fillTheScreenWithInitialData];
    }
    
    // Dismiss the keyboard on backgroundtap.
    [self startResigningFirstResponderOnBackgroundTap];
//
//    NSNotificationCenter *notificationCenter = NSNotificationCenter.defaultCenter;
//    __weak typeof(self) weakSelf = self;
//    _emailFieldDidEndEditingObserver = [notificationCenter addObserverForName:UITextFieldTextDidEndEditingNotification object:_emailField queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
//        NSLog(@"Godverdomme");
//        weakSelf.emailField.inputView = nil;
//        weakSelf.emailTextInputReceiver.target = MCEmailTextInputProxyTargetValidator;
//    }];
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//
//    _emailFieldDidEndEditingObserver = nil;
}

#pragma mark - UIResponder

#pragma mark - NSObject

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _emailAddressStringInTextField = MCStatusInvalid;
}

@end
