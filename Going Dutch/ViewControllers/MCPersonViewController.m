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

@interface MCPersonViewController ()

@end

@implementation MCPersonViewController

@synthesize tonightsBill;
@synthesize changeFlagDelegate;
@synthesize isNew;
@synthesize thisPerson;

#pragma mark - Actions

- (IBAction)dismissKeyboard:(id)sender
{
    if ([firstNameField isFirstResponder]) {
        [firstNameField endEditing:YES];
    }
    if ([lastNameField isFirstResponder]) {
        [lastNameField endEditing:YES];
    }
    if ([emailField isFirstResponder]) {
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            [self cancelEmailPicker:self];
        } else {
            [emailField endEditing:YES];
        }
    }
}

- (IBAction)cancelButtonPressed:(id)sender
{
    //[[[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext] rollback];
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlock:^{
        [[context undoManager] endUndoGrouping];
        [[context undoManager] undoNestedGroup];
    }];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonPressed:(id)sender
{
    if (isNew && (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied || ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)) {
        if ([firstNameField isFirstResponder]) {
            [firstNameField resignFirstResponder];
        } else if ([lastNameField isFirstResponder]) {
            [lastNameField resignFirstResponder];
        } else if ([emailField isFirstResponder]) {
            [emailField resignFirstResponder];
        }
    }
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlock:^{
        [thisPerson setDateModified:[NSDate date]];
        [[context undoManager] endUndoGrouping];
    }];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)getSomeone:(id)selector
{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    if (!personReceiver) {
        personReceiver = [[MCAddressBookDataReceiver alloc] initWithViewController:self andDelegate:self];
        [personReceiver setThisPerson:thisPerson];
    }
    [peoplePicker setPeoplePickerDelegate:personReceiver];
    [peoplePicker setEdgesForExtendedLayout:UIRectEdgeNone];
    [[[peoplePicker viewControllers] objectAtIndex:0] setEdgesForExtendedLayout:UIRectEdgeNone];
    [peoplePicker setModalPresentationStyle:UIModalPresentationFormSheet];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [MCTools setAdBannerIfNotPaid:NO forViewController:[[peoplePicker viewControllers] objectAtIndex:0]];
    } else {
        [MCTools setAdBannerIfNotPaid:YES forViewController:[[peoplePicker viewControllers] objectAtIndex:0]];
    }
    [[self navigationController] presentViewController:peoplePicker animated:YES completion:nil];
}

- (void)doneEmailPicker:(id)selector
{
    MCEmailAddress *newDefaultEmailAddress = [[dataController fetchedObjects] objectAtIndex:[emailSelectionFromAddressBookPickerView selectedRowInComponent:0]];
    MCEmailAddress *oldDefaulEmailAddress = [MCEmailAddress fetchEmailAddressFor:thisPerson];
    [oldDefaulEmailAddress setSelected:[NSNumber numberWithBool:NO]];
    [newDefaultEmailAddress setSelected:[NSNumber numberWithBool:YES]];
    [emailField setText:[thisPerson defaultEmailAddress]];
    
    [emailField resignFirstResponder];
    didSomethingChange = YES;
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
}

- (void)cancelEmailPicker:(id)selector
{
    [emailField setText:[thisPerson defaultEmailAddress]];
    [emailField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    /*
    if (thisPersonHasPaidSomething) {
        if (textField == firstNameField || textField == lastNameField) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return YES;
    }
     */
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == emailField) {
        // Set the UIPickerView as keyboard for the emailfield if Access to the AddressBook is authorized.
        if (kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus() /*&& [[thisPerson emailAddress] count] > 0*/) {
            NSUInteger indexOfDefaultEmailAddress = [[dataController fetchedObjects] indexOfObject:[thisPerson getDefaultEmailAddressObject]];
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
                NSArray *buttonArray = [[NSArray alloc] initWithObjects:cancelButton, flexButton, doneButton, nil];
                [inputAccessoryPickerView setItems:buttonArray animated:YES];
                if (!emailSelectionFromAddressBookPickerView) {
                    emailSelectionFromAddressBookPickerView = [[UIPickerView alloc] init];
                    [emailSelectionFromAddressBookPickerView setDelegate:self];
                    [emailSelectionFromAddressBookPickerView setDataSource:self];
                    [emailSelectionFromAddressBookPickerView setShowsSelectionIndicator:YES];
                    [emailField setInputView:emailSelectionFromAddressBookPickerView];
                    [emailField setInputAccessoryView:inputAccessoryPickerView];
                }
                
                [emailSelectionFromAddressBookPickerView selectRow:indexOfDefaultEmailAddress inComponent:0 animated:YES];
                UIToolbar *inputAccossoryNumberPad = [[UIToolbar alloc] initWithFrame:toolbarRect];
                cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                             target:self
                                                                             action:@selector(cancelNumberPad:)];
                doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                           target:self
                                                                           action:@selector(doneNumberPad:)];
                [inputAccossoryNumberPad setItems:[[NSArray alloc] initWithObjects:cancelButton, flexButton, doneButton, nil] animated:YES];
            }
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == firstNameField) {
        [thisPerson setFirstName:[firstNameField text]];
        didSomethingChange = YES;
        NSDate *nu = [NSDate date];
        [tonightsBill setDateModified:nu];
        [thisPerson setDateModified:nu];
        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
        [lastNameField becomeFirstResponder];
    } else if (textField == lastNameField) {
        [thisPerson setLastName:[lastNameField text]];
        didSomethingChange = YES;
        NSDate *nu = [NSDate date];
        [tonightsBill setDateModified:nu];
        [thisPerson setDateModified:nu];
        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
        [emailField becomeFirstResponder];
    } else if (textField == emailField) {
        if (kABAuthorizationStatusDenied == ABAddressBookGetAuthorizationStatus() || kABAuthorizationStatusRestricted == ABAddressBookGetAuthorizationStatus()) {
            if (isNew) {
                [thisPerson addOneEmailAddressFromAString:[emailField text]];
            } else {
                MCEmailAddress *defaultEmail = [thisPerson getDefaultEmailAddressObject];
                if (!defaultEmail) {
                    [thisPerson addOneEmailAddressFromAString:[emailField text]];
                } else {
                    [defaultEmail setEmailAddress:[emailField text]];
                }
            }
        } else if (kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus()) {
            NSUInteger indexOfDefaultEmailAddress = [[dataController fetchedObjects] indexOfObject:[thisPerson getDefaultEmailAddressObject]];
            if (indexOfDefaultEmailAddress > [[dataController fetchedObjects] count]) {
                [thisPerson addOneEmailAddressFromAString:[emailField text]];
            }
        }
        NSDate *nu = [NSDate date];
        [tonightsBill setDateModified:nu];
        [thisPerson setDateModified:nu];
        didSomethingChange = YES;
        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
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
        [emailField resignFirstResponder];
        return YES;
    }
    return NO;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    MCEmailAddress *emailAddressObject = [[dataController fetchedObjects] objectAtIndex:row];
    return [emailAddressObject emailAddress];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    MCEmailAddress *pickedEmailAddress = [[dataController fetchedObjects] objectAtIndex:row];
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
    // return [tonightsBill isPersonPresent:newPerson];
    NSLog(@"isNewPersonFromAddressBookAlreadyPresent is not implemented yet.");
    return NO;
}

- (MCPerson *)personRecordToUse
{
    if (!isNew) {
        return thisPerson;
    } else {
        return nil;
    }
}

- (void)receiveANewPersonFromAddressBook:(MCPerson *)newPerson
{
    didSomethingChange = YES;
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    [emailSelectionFromAddressBookPickerView reloadComponent:0];
}

#pragma mark - New in this class

- (id)initWithPerson:(MCPerson *)person 
{
    self = [super init];
    
    if (self) {
        if (!person) {
            @throw [NSException exceptionWithName:@"nil" reason:@"person is nil" userInfo:nil];
        }
        thisPerson = person;
        didSomethingChange = NO;
        emailEditFieldStatus = 0;
    }
    return self;
}

- (void)prepareDataController
{
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    // Set dataController for EmailPicker
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCEmailAddress"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"owner = %@", thisPerson]];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"emailAddress" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sd]];
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

#pragma mark - Inherited from super.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!twoLabelTitleView) {
        twoLabelTitleView = [[[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil] objectAtIndex:0];
        if (isNew) {
            [[twoLabelTitleView mainLabel] setText:@"New person"];
            [[twoLabelTitleView subLabel] setText:@"Add"];
        } else {
            [[twoLabelTitleView mainLabel] setText:@"Person"];
            if (kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus()) {
                [[twoLabelTitleView subLabel] setText:@"Show details"];
            } else {
                [[twoLabelTitleView subLabel] setText:@"Edit details"];
            }
        }
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            [[twoLabelTitleView mainLabel] setTextColor:[UIColor whiteColor]];
            [[twoLabelTitleView subLabel] setTextColor:[UIColor whiteColor]];
        }
        [[self navigationItem] setTitleView:twoLabelTitleView];
    }
    
    [self performFetch];
    if (kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus()) {
        // When dataController is empty there are no email addresses.
        if ([[dataController fetchedObjects] count] <= 1) {
            [emailField setPlaceholder:@"no emailaddresses"];
            [emailField setEnabled:NO];
        } else {
            [emailField setPlaceholder:@"e-mail address"];
            [emailField setEnabled:YES];
        }
    }
    
    [[[self navigationItem] rightBarButtonItem] setEnabled:didSomethingChange];
    [addressBookButton setEnabled:!thisPersonHasPaidSomething];
    [[self navigationController] setToolbarHidden:NO animated:animated];
    [firstNameField setText:[thisPerson firstName]];
    [lastNameField setText:[thisPerson lastName]];
    MCEmailAddress *emailAddress = [MCEmailAddress fetchEmailAddressFor:thisPerson];
    [emailField setText:[emailAddress emailAddress]];
    [pictureView setImage:[thisPerson picture]];
    NSNumber *moneySpendByThisPerson = [tonightsBill totalSumPaidBy:thisPerson];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [totalSumSpendLabel setText:[NSString stringWithFormat:@"Spent %@", [nf stringFromNumber:moneySpendByThisPerson]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // When on iPhone show a banner.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [MCTools setAdBannerIfNotPaid:NO forViewController:self];
    } else {
        [MCTools setAdBannerIfNotPaid:YES forViewController:self];
    }
    
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [[context undoManager] beginUndoGrouping];
    
    [self prepareDataController];
    
    if (!thisPerson) {
        thisPerson = [tonightsBill addPerson];
        [thisPerson setThumbnailDataFromImage:nil];
        [thisPerson setPictureDataFromImage:nil];
        [tonightsBill addPeoplePresentObject:thisPerson];
        thisPersonHasPaidSomething = NO;
    } else if ([tonightsBill hasPersonPaidSomething:thisPerson]) { // Check to see if thisPerson has paid something.
        thisPersonHasPaidSomething = YES;
    } else {
        thisPersonHasPaidSomething = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
