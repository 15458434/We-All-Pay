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

#import "MCTwoLabelsTitleView.h"

#import "MCTools.h"

typedef NS_ENUM(BOOL, MCStatus) {
    inValid,
    valid
};

@interface MCPersonViewController ()

@property (atomic, copy) NSDate * dateModified;
@property (atomic, copy) NSString * defaultEmailAddress;
@property (atomic, copy) NSString * firstName;
@property (atomic, copy) NSString * lastName;
@property (atomic, strong) NSString * phoneNumber;
@property (atomic, copy) UIImage * picture;
@property (atomic, copy) UIImage * thumbnail;

@property (nonatomic) MCStatus emailAddressStringInTextField;

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
    isSelectEmail = YES;
    [emailField becomeFirstResponder];
}

- (IBAction)doneButtonPressed:(id)sender
{
    [self dismissKeyboard];
    [_thisPerson setDateModified:[NSDate date]];
    [[MCWeAllPayStoreController defaultStore] endUndoGroupAndProcess];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)getSomeone:(id)selector
{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    if (!personReceiver) {
        personReceiver = [[MCAddressBookDataReceiver alloc] initWithViewController:self andDelegate:self];
        [personReceiver setThisPerson:_thisPerson];
    }
    [peoplePicker setPeoplePickerDelegate:personReceiver];
    [peoplePicker setEdgesForExtendedLayout:UIRectEdgeNone];
    [[peoplePicker viewControllers][0] setEdgesForExtendedLayout:UIRectEdgeNone];
    [peoplePicker setModalPresentationStyle:UIModalPresentationFormSheet];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [MCTools setAdBannerIfNotPaid:NO forViewController:[peoplePicker viewControllers][0]];
    } else {
        [MCTools setAdBannerIfNotPaid:YES forViewController:[peoplePicker viewControllers][0]];
    }
    [[self navigationController] presentViewController:peoplePicker animated:YES completion:nil];
}

- (void)doneEmailPicker:(id)selector
{
    MCEmailAddress *newDefaultEmailAddress = [dataController fetchedObjects][[emailSelectionFromAddressBookPickerView selectedRowInComponent:0]];
    MCEmailAddress *oldDefaulEmailAddress = [MCEmailAddress fetchEmailAddressFor:_thisPerson];
    [oldDefaulEmailAddress setSelected:@NO];
    [newDefaultEmailAddress setSelected:@YES];
    [emailField setText:[_thisPerson defaultEmailAddress]];
    
    [emailField resignFirstResponder];
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
}

- (void)cancelEmailPicker:(id)selector
{
    [emailField setText:[_thisPerson defaultEmailAddress]];
    [emailField resignFirstResponder];
}

#pragma mark - New in this class

- (id)initWithPerson:(MCPerson *)person 
{
    self = [super init];
    
    if (self) {
        if (!person) {
            @throw [NSException exceptionWithName:@"nil" reason:@"person is nil" userInfo:nil];
        }
        _thisPerson = person;
        emailEditFieldStatus = 0;
    }
    return self;
}

- (void)dismissKeyboard
{
    if ([firstNameField isFirstResponder]) {
        [firstNameField endEditing:YES];
    }
    if ([lastNameField isFirstResponder]) {
        [lastNameField endEditing:YES];
    }
    if ([emailField isFirstResponder]) {
        if (isSelectEmail) {
            [self cancelEmailPicker:self];
        } else {
            [emailField endEditing:YES];
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
    dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
}

- (void)performFetch
{
    NSError *error = nil;
    [dataController performFetch:&error];
    if (error) {
        NSLog(@"Something went wrong fetching email addresses: %@", [error localizedDescription]);
    }
}

- (void)prepareEmailFieldAsSelector
{
    NSUInteger indexOfDefaultEmailAddress = [[dataController fetchedObjects] indexOfObject:[_thisPerson getDefaultEmailAddressObject]];
    if (indexOfDefaultEmailAddress < [[dataController fetchedObjects] count]) {
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
        if (!emailSelectionFromAddressBookPickerView) {
            emailSelectionFromAddressBookPickerView = [[UIPickerView alloc] init];
            [emailSelectionFromAddressBookPickerView setDelegate:self];
            [emailSelectionFromAddressBookPickerView setDataSource:self];
            [emailSelectionFromAddressBookPickerView setShowsSelectionIndicator:YES];
        }
        [emailField setInputView:emailSelectionFromAddressBookPickerView];
        [emailField setInputAccessoryView:inputAccessoryPickerView];
        
        [emailSelectionFromAddressBookPickerView selectRow:indexOfDefaultEmailAddress inComponent:0 animated:YES];
        UIToolbar *inputAccossoryNumberPad = [[UIToolbar alloc] initWithFrame:toolbarRect];
        cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                     target:self
                                                                     action:@selector(cancelNumberPad:)];
        doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                   target:self
                                                                   action:@selector(doneNumberPad:)];
        [inputAccossoryNumberPad setItems:@[cancelButton, flexButton, doneButton] animated:YES];
    } else {
        isSelectEmail = NO;
    }
}

#pragma mark - Private in this class

- (void)fillTheScreenWithInitialData
{
    // Should be execute on the mainThread.
    [firstNameField setText:[_thisPerson firstName]];
    [lastNameField setText:[_thisPerson lastName]];
    MCEmailAddress *emailAddress = [MCEmailAddress fetchEmailAddressFor:_thisPerson];
    [emailField setText:[emailAddress emailAddress]];
    _pictureView.image = _thisPerson.picture;
    if ([[_thisPerson emailAddress] count] < 2) {
        [selectEmailAddressButton setHidden:YES];
    } else {
        [selectEmailAddressButton setHidden:NO];
    }
}

#pragma mark - Inherited from super.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _emailAddressStringInTextField = inValid;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self prepareDataController];
    
    if (!_thisPerson) {
//        _thisPerson = [tonightsBill addPerson];
//        [_thisPerson setThumbnailDataFromImage:nil];
//        [_thisPerson setPictureDataFromImage:nil];
//        [tonightsBill addPeoplePresentObject:_thisPerson];
        // A new person object will be delivered
        thisPersonHasPaidSomething = NO;
    } else if ([_tonightsBill hasPersonPaidSomething:_thisPerson]) { // Check to see if thisPerson has paid something.
        thisPersonHasPaidSomething = YES;
    } else {
        thisPersonHasPaidSomething = NO;
    }
    
    isSelectEmail = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setToolbarHidden:YES animated:YES];
    
    if (!twoLabelTitleView) {
        twoLabelTitleView = [[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil][0];
        if (isNew) {
            [[twoLabelTitleView mainLabel] setText:NSLocalizedString(@"NEW_PERSON_HEADER", @"Header in the personView which state new person.")];
            [[twoLabelTitleView subLabel] setText:NSLocalizedString(@"NEW_PERSON_SUBHEADER", @"Sub header in the personView which states add new data")];
        } else {
            [[twoLabelTitleView mainLabel] setText:NSLocalizedString(@"EXISTING_PERSON_HEADER", @"Header in the personView which states person")];
            [[twoLabelTitleView subLabel] setText:NSLocalizedString(@"EXISTING_PERSON_SUBHEADER", @"Sub header in the personView which state edit data")];
        }
//        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
//            [[twoLabelTitleView mainLabel] setTextColor:[UIColor whiteColor]];
//            [[twoLabelTitleView subLabel] setTextColor:[UIColor whiteColor]];
//        }
        [[self navigationItem] setTitleView:twoLabelTitleView];
    }
    
    [self performFetch];

    if (_thisPerson) {
        [self fillTheScreenWithInitialData];
    }
    [selectEmailAddressButton setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    if (isNew) {
//        [tracker set:kGAIScreenName value:@"MCPersonNewView_iPhone"];
//    } else {
//        [tracker set:kGAIScreenName value:@"MCPersonDetails_iPhone"];
//    }
//    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
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

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
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
    if (textField == emailField) {
        if (isSelectEmail) {
            [self prepareEmailFieldAsSelector];
        } else {
            [emailField setInputView:nil];
            [emailField setInputAccessoryView:nil];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == firstNameField) {
        [_thisPerson setFirstName:[firstNameField text]];
        NSDate *nu = [NSDate date];
        [_tonightsBill setDateModified:nu];
        [_thisPerson setDateModified:nu];
    } else if (textField == lastNameField) {
        [_thisPerson setLastName:[lastNameField text]];
        NSDate *nu = [NSDate date];
        [_tonightsBill setDateModified:nu];
        [_thisPerson setDateModified:nu];
    } else if (textField == emailField) {
        if (!isSelectEmail) {
            [emailField setInputView:nil];
            [emailField setInputAccessoryView:nil];
            if (isNew) {
                [_thisPerson addOneEmailAddressFromAString:[emailField text]];
            } else {
                MCEmailAddress *defaultEmail = [_thisPerson getDefaultEmailAddressObject];
                if (!defaultEmail) {
                    [_thisPerson addOneEmailAddressFromAString:[emailField text]];
                } else {
                    [defaultEmail setEmailAddress:[emailField text]];
                }
            }
        }
        isSelectEmail = NO;
        NSDate *nu = [NSDate date];
        [_tonightsBill setDateModified:nu];
        [_thisPerson setDateModified:nu];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == firstNameField) {
        [firstNameField resignFirstResponder];
        return YES;
    } else if (textField == lastNameField) {
        [lastNameField resignFirstResponder];
        return YES;
    } else if (textField == emailField) {
        if ([MCTools isStringAnEmailAddress:[emailField text]]) {
            _emailAddressStringInTextField = valid;
            [emailField setTextColor:[UIColor blackColor]];
            [emailField resignFirstResponder];
            return YES;
        } else {
            _emailAddressStringInTextField = inValid;
            [emailField setTextColor:[UIColor redColor]];
        }
    }
    return NO;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    MCEmailAddress *emailAddressObject = [dataController fetchedObjects][row];
    return [emailAddressObject emailAddress];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    MCEmailAddress *pickedEmailAddress = [dataController fetchedObjects][row];
    [emailField setText:[pickedEmailAddress emailAddress]];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus()) {
        return [[dataController fetchedObjects] count];
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
    [emailSelectionFromAddressBookPickerView reloadComponent:0];
}

@end
