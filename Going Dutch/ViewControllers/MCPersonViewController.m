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

@interface MCPersonViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) MCTwoLabelsTitleView *twoLabelTitleView;

@property (nonatomic, weak) IBOutlet UIImageView *pictureView;
@property (nonatomic, weak) IBOutlet UITextField *firstNameField;
@property (nonatomic, strong) MCNameTextInputValidator *firstNameFieldValidator;
@property (nonatomic, weak) IBOutlet UITextField *lastNameField;
@property (nonatomic, strong) MCNameTextInputValidator *familyNameFieldValidator;
@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UIButton *selectEmailAddressButton;
@property (nonatomic, strong) MCEmailTextInputProxy *emailTextInputReceiver;

@property (nonatomic, strong) IBOutlet MCPersonModel *model;

@end

@implementation MCPersonViewController

- (IBAction)cancelButtonPressed:(id)sender
{
    [FIRAnalytics logEventWithName:@"Cancel button pressed" parameters:nil];
    [self.view endEditing:YES];
    [[MCWeAllPayStoreController defaultStore] endUndoGroupAndUndo];
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
    [[MCWeAllPayStoreController defaultStore] endUndoGroupAndProcess];
    [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    NSAssert((indexPath.section == 0), @"IndexPath section should be 0");
    if ([controller isEqual:_model.personFetchedResultsController]) {
        MCPerson *person = (MCPerson *)anObject;
        switch (type) {
            case NSFetchedResultsChangeInsert:
                self.firstNameField.text = person.firstName;
                self.lastNameField.text = person.lastName;
                self.pictureView.image = person.picture;
                break;
            case NSFetchedResultsChangeUpdate:
                self.firstNameField.text = person.firstName;
                self.lastNameField.text = person.lastName;
                self.pictureView.image = person.picture;
                break;
            case NSFetchedResultsChangeMove:
                NSParameterAssert(NO);
                break;
            case NSFetchedResultsChangeDelete:
                break;
            default:
                break;
        }
    } else if ([controller isEqual:_model.defaultEmailAddressFetchedResultsController]) {
        switch (type) {
            case NSFetchedResultsChangeInsert:
                self.emailField.text = [(MCEmailAddress *)anObject emailAddress];
                break;
            case NSFetchedResultsChangeUpdate:
                self.emailField.text = [(MCEmailAddress *)anObject emailAddress];
                break;
            case NSFetchedResultsChangeMove:
                NSParameterAssert(NO);
                break;
            case NSFetchedResultsChangeDelete:
                break;
            default:
                break;
        }
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    [_model prepareForUseWithPerson:_thisPerson andFetchedResultsControllerDelegate:self andChangeHandler:^(MCPerson * _Nonnull person) {
        typeof(self) strongSelf = weakSelf;
        NSParameterAssert(strongSelf);
        
        strongSelf.emailField.inputView = nil;
        strongSelf.emailField.tintColor = UIColor.systemBlueColor;
        strongSelf.emailTextInputReceiver.target = MCEmailTextInputProxyTargetValidator;
        strongSelf.selectEmailAddressButton.hidden = person.emailAddress.count > 1 ? NO : YES;
    }];
    _firstNameFieldValidator = [[MCNameTextInputValidator alloc] initWithModel:_model andTextField:_firstNameField andConfig:MCNameTextInputValidatorConfigFirstName];
    _familyNameFieldValidator = [[MCNameTextInputValidator alloc] initWithModel:_model andTextField:_lastNameField andConfig:MCNameTextInputValidatorConfigFamilyName];
    MCEmailTextInputValidator *validator = [[MCEmailTextInputValidator alloc] initWithTextField:_emailField andModel:_model];
    MCEmailTextInputPicker *picker = [[MCEmailTextInputPicker alloc] initWithTextField:_emailField andModel:_model];
    _emailTextInputReceiver = [[MCEmailTextInputProxy alloc] initWithValidator:validator andPicker:picker andTarget:MCEmailTextInputProxyTargetValidator];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.firstNameField.text = _model.person.firstName;
    self.lastNameField.text = _model.person.lastName;
    self.emailField.text = _model.person.defaultEmailAddress;
    self.pictureView.image = _model.person.picture;
    self.selectEmailAddressButton.hidden = _model.person.emailAddress.count > 1 ? NO : YES;
    
    [[self navigationController] setToolbarHidden:YES animated:YES];
    
    if (!_twoLabelTitleView) {
        _twoLabelTitleView = [[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil][0];
        if (_isNew) {
            _twoLabelTitleView.mainLabel.text = NSLocalizedString(@"NEW_PERSON_HEADER", @"Header in the personView which state new person.");
            _twoLabelTitleView.subLabel.text = NSLocalizedString(@"NEW_PERSON_SUBHEADER", @"Sub header in the personView which states add new data");
        } else {
            _twoLabelTitleView.mainLabel.text = NSLocalizedString(@"EXISTING_PERSON_HEADER", @"Header in the personView which states person");
            _twoLabelTitleView.subLabel.text = NSLocalizedString(@"EXISTING_PERSON_SUBHEADER", @"Sub header in the personView which state edit data");
        }

        self.navigationItem.titleView = _twoLabelTitleView;
    }
    
    // Dismiss the keyboard on backgroundtap.
    [self startResigningFirstResponderOnBackgroundTap];
}

#pragma mark - UIResponder

#pragma mark - NSObject

@end
