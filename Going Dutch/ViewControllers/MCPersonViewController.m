//
//  MCPersonViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 31-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPersonViewController.h"

#import "MCWeAllPayStoreController.h"
#import "MCPerson+addons.h"
#import "MCSharedBill+addons.h"
#import "MCEmailAddress+addons.h"

#import "MCTools.h"

typedef NS_ENUM(BOOL, MCStatus) {
    invalidStatus,
    validStatus
};

@interface MCPersonViewController ()

@property (nonatomic, weak) IBOutlet UITextField *firstNameField;
@property (nonatomic, weak) IBOutlet UITextField *lastNameField;
@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UIButton *selectEmailAddressButton;

@property (nonatomic, strong) MCTwoLabelsTitleView *twoLabelTitleView;
@property (nonatomic, strong) UIBarButtonItem *addressBookButton;
@property (nonatomic, strong) UIPickerView *emailSelectionFromAddressBookPickerView;
@property (nonatomic) BOOL isSelectEmail;
@property (nonatomic) NSUInteger emailEditFieldStatus;

@property (nonatomic, strong) MCAddressBookDataReceiver *personReceiver;
@property (nonatomic, strong) NSFetchedResultsController *dataController;

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

#pragma mark - Actions

- (IBAction)dismissKeyboard:(id)sender
{
    [self dismissKeyboard];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissKeyboard];
    [[MCWeAllPayStoreController defaultStore] endUndoGroupAndUndo];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectEmailAddressPressed:(id)sender
{
    // If any of the fields is first responder resign them first.
    [self dismissKeyboard];
    
    // select the emailField and pop-up it's keyboard with the UIPickerView
    _isSelectEmail = YES;
    [_emailField becomeFirstResponder];
}

- (IBAction)doneButtonPressed:(id)sender
{
    [self dismissKeyboard];
    [_thisPerson setDateModified:[NSDate date]];
    [[MCWeAllPayStoreController defaultStore] endUndoGroupAndProcess];
    [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneEmailPicker:(id)selector
{
    MCEmailAddress *newDefaultEmailAddress = [_dataController fetchedObjects][[_emailSelectionFromAddressBookPickerView selectedRowInComponent:0]];
    MCEmailAddress *oldDefaulEmailAddress = [MCEmailAddress fetchEmailAddressFor:_thisPerson];
    [oldDefaulEmailAddress setSelected:@NO];
    [newDefaultEmailAddress setSelected:@YES];
    [_emailField setText:[_thisPerson defaultEmailAddress]];
    
    [_emailField resignFirstResponder];
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
}

- (void)cancelEmailPicker:(id)selector
{
    [_emailField setText:[_thisPerson defaultEmailAddress]];
    [_emailField resignFirstResponder];
}

#pragma mark - New in this class

- (void)dismissKeyboard
{
    if ([_firstNameField isFirstResponder]) {
        [_firstNameField endEditing:YES];
    }
    if ([_lastNameField isFirstResponder]) {
        [_lastNameField endEditing:YES];
    }
    if ([_emailField isFirstResponder]) {
        if (_isSelectEmail) {
            [self cancelEmailPicker:self];
        } else {
            [_emailField endEditing:YES];
        }
    }
}

- (void)prepareDataController
{
    NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
    // Set dataController for EmailPicker
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCEmailAddress"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"owner = %@", _thisPerson]];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"emailAddress" ascending:YES];
    [request setSortDescriptors:@[sd]];
    _dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
}

- (void)performFetch
{
    NSError *error = nil;
    [_dataController performFetch:&error];
    if (error) {
        NSLog(@"Something went wrong fetching email addresses: %@", error);
    }
}

- (void)prepareEmailFieldAsSelector
{
    NSUInteger indexOfDefaultEmailAddress = [[_dataController fetchedObjects] indexOfObject:[_thisPerson getDefaultEmailAddressObject]];
    if (indexOfDefaultEmailAddress < [[_dataController fetchedObjects] count]) {
        CGRect toolbarRect = CGRectMake(0, 0, [[self view] bounds].size.width, 44);
        UIToolbar *inputAccessoryPickerView = [[UIToolbar alloc] initWithFrame:toolbarRect];
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                      target:self
                                                                                      action:@selector(cancelEmailPicker:)];
        UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:nil
                                                                                    action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self
                                                                                    action:@selector(doneEmailPicker:)];
        NSArray *buttonArray = @[cancelButton, flexButton, doneButton];
        [inputAccessoryPickerView setItems:buttonArray animated:YES];
        if (!_emailSelectionFromAddressBookPickerView) {
            _emailSelectionFromAddressBookPickerView = [[UIPickerView alloc] init];
            [_emailSelectionFromAddressBookPickerView setDelegate:self];
            [_emailSelectionFromAddressBookPickerView setDataSource:self];
            [_emailSelectionFromAddressBookPickerView setShowsSelectionIndicator:YES];
        }
        [_emailField setInputView:_emailSelectionFromAddressBookPickerView];
        [_emailField setInputAccessoryView:inputAccessoryPickerView];
        
        [_emailSelectionFromAddressBookPickerView selectRow:indexOfDefaultEmailAddress inComponent:0 animated:YES];
        UIToolbar *inputAccossoryNumberPad = [[UIToolbar alloc] initWithFrame:toolbarRect];
        cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                     target:self
                                                                     action:@selector(cancelNumberPad:)];
        doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                   target:self
                                                                   action:@selector(doneNumberPad:)];
        [inputAccossoryNumberPad setItems:@[cancelButton, flexButton, doneButton] animated:YES];
    } else {
        _isSelectEmail = NO;
    }
}

#pragma mark - Private in this class

- (void)fillTheScreenWithInitialData
{
    // Should be execute on the mainThread.
    [_firstNameField setText:[_thisPerson firstName]];
    [_lastNameField setText:[_thisPerson lastName]];
    MCEmailAddress *emailAddress = [MCEmailAddress fetchEmailAddressFor:_thisPerson];
    [_emailField setText:[emailAddress emailAddress]];
    _pictureView.image = _thisPerson.picture;
    if ([[_thisPerson emailAddress] count] < 2) {
        [_selectEmailAddressButton setHidden:YES];
    } else {
        [_selectEmailAddressButton setHidden:NO];
    }
}

#pragma mark - Inherited from super.

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _emailAddressStringInTextField = invalidStatus;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self prepareDataController];
    
    if (!_thisPerson) {
        // A new person object will be delivered
        _thisPersonHasPaidSomething = NO;
    } else if ([_tonightsBill hasPersonPaidSomething:_thisPerson]) { // Check to see if thisPerson has paid something.
        _thisPersonHasPaidSomething = YES;
    } else {
        _thisPersonHasPaidSomething = NO;
    }
    
    _isSelectEmail = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setToolbarHidden:YES animated:YES];
    
    if (!_twoLabelTitleView) {
        _twoLabelTitleView = [[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil][0];
        if (isNew) {
            [[_twoLabelTitleView mainLabel] setText:NSLocalizedString(@"NEW_PERSON_HEADER", @"Header in the personView which state new person.")];
            [[_twoLabelTitleView subLabel] setText:NSLocalizedString(@"NEW_PERSON_SUBHEADER", @"Sub header in the personView which states add new data")];
        } else {
            [[_twoLabelTitleView mainLabel] setText:NSLocalizedString(@"EXISTING_PERSON_HEADER", @"Header in the personView which states person")];
            [[_twoLabelTitleView subLabel] setText:NSLocalizedString(@"EXISTING_PERSON_SUBHEADER", @"Sub header in the personView which state edit data")];
        }

        [[self navigationItem] setTitleView:_twoLabelTitleView];
    }
    
    [self performFetch];

    if (_thisPerson) {
        [self fillTheScreenWithInitialData];
    }
    
    // Dismiss the keyboard on backgroundtap.
    [self startResigningFirstResponderOnBackgroundTap];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [MCTools setAdBannerIfNotPaid:NO forViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSNotifications

//- (void)writableThisPersonIsCreated:(NSNotification *)notification
//{
//    // Should be executed on the background thread.
//}

- (void)writableTonightsBillIsCreated:(NSNotification *)notification
{
    // Should be executed on the background thread.
    _writableTonightsBill = [[notification userInfo] objectForKey:MCwritableTonightsBillKey];
    _writableThisPerson = [_writableTonightsBill addPerson];
    NSLog(@"MCPersonViewController: writableTonightsBill is created.");
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf fillTheScreenWithInitialData];
        }
    });
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _emailField) {
        if (_isSelectEmail) {
            [self prepareEmailFieldAsSelector];
        } else {
            [_emailField setInputView:nil];
            [_emailField setInputAccessoryView:nil];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _firstNameField) {
        [_thisPerson setFirstName:[_firstNameField text]];
        NSDate *nu = [NSDate date];
        [_tonightsBill setDateModified:nu];
        [_thisPerson setDateModified:nu];
    } else if (textField == _lastNameField) {
        [_thisPerson setLastName:[_lastNameField text]];
        NSDate *nu = [NSDate date];
        [_tonightsBill setDateModified:nu];
        [_thisPerson setDateModified:nu];
    } else if (textField == _emailField) {
        if (!_isSelectEmail) {
            [_emailField setInputView:nil];
            [_emailField setInputAccessoryView:nil];
            if (isNew) {
                [_thisPerson addOneEmailAddressFromAString:[_emailField text]];
            } else {
                MCEmailAddress *defaultEmail = [_thisPerson getDefaultEmailAddressObject];
                if (!defaultEmail) {
                    [_thisPerson addOneEmailAddressFromAString:[_emailField text]];
                } else {
                    [defaultEmail setEmailAddress:[_emailField text]];
                }
            }
        }
        _isSelectEmail = NO;
        NSDate *nu = [NSDate date];
        [_tonightsBill setDateModified:nu];
        [_thisPerson setDateModified:nu];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _firstNameField) {
        [_firstNameField resignFirstResponder];
        return YES;
    } else if (textField == _lastNameField) {
        [_lastNameField resignFirstResponder];
        return YES;
    } else if (textField == _emailField) {
        if ([MCTools isStringAnEmailAddress:[_emailField text]]) {
            _emailAddressStringInTextField = validStatus;
            [_emailField setTextColor:[UIColor blackColor]];
            [_emailField resignFirstResponder];
            return YES;
        } else {
            _emailAddressStringInTextField = invalidStatus;
            [_emailField setTextColor:[UIColor redColor]];
        }
    }
    return NO;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    MCEmailAddress *emailAddressObject = [_dataController fetchedObjects][row];
    return [emailAddressObject emailAddress];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    MCEmailAddress *pickedEmailAddress = [_dataController fetchedObjects][row];
    [_emailField setText:[pickedEmailAddress emailAddress]];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus()) {
        return [[_dataController fetchedObjects] count];
    } else {
        return 1;
    }
}

#pragma mark - MCAddressBookReceiverDelegate

- (BOOL)isPersonAlreadyPresent:(MCPerson *)newPerson
{
    NSLog(@"isNewPersonFromAddressBookAlreadyPresent is not implemented yet.");
    return NO;
}

- (MCPerson *)personRecordToUse
{
    if (!isNew) {
        return _thisPerson;
    } else {
        return nil;
    }
}

- (void)receiveANewPersonFromAddressBook:(MCPerson *)newPerson
{
//    didSomethingChange = YES;
    [_emailSelectionFromAddressBookPickerView reloadComponent:0];
}

@end
