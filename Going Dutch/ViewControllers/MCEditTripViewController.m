//
//  MCPeopleViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 25-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCEditTripViewController.h"
#import "MCPersonViewController.h"
#import "MCSharedBillTableViewController.h"
#import "MCSharedBillPageViewController.h"
#import "UIViewController+WeAllPayStore.h"

#import "MCWeAllPayStoreController.h"
#import "MCPerson+addons.h"
#import "MCSharedBill+addons.h"
#import "MCCurrency+addons.h"

#import "We_all_pay-Swift.h"

@interface MCEditTripViewController ()

@property (weak, nonatomic) IBOutlet UIButton *addPersonButton;

@property (weak, nonatomic) IBOutlet UIButton *contactsButton;
@property (weak, nonatomic) IBOutlet PaymentsSwipeDirectionHintView *paymentsHintsView;

@property (weak, nonatomic) IBOutlet UITextField *tripNameField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet MCTwoLabelsTitleView *twoLabelTitleView;

@property (strong, nonatomic) MCTableEmptyMessage *emptyMessage;

@property (nonatomic, strong) NSFetchedResultsController *dataController;
@property (nonatomic, strong) MCAddressBookDataReceiver *personReceiver;

@property (nonatomic) BOOL cancelPressed;

@end

@implementation MCEditTripViewController

@synthesize dismissOnDone;
@synthesize dismissOnCancel;

@synthesize didSomethingChange;

@synthesize delegate;

#pragma mark - actions of this class

- (IBAction)addressBookButton:(id)sender {
    
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
                NSLog(@"Something went wrong opening myAddressBook: %@", error);
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


- (IBAction)addPersonButton:(id)sender {
    if ([_tripNameField isEditing]) {
        [_tripNameField resignFirstResponder];
    }
}

- (void)tappedInTheBackground:(id)sender
{
    [_tripNameField resignFirstResponder];
}

#pragma mark - new in this class.

- (void)openPeoplePicker
{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    if (!_personReceiver) {
        _personReceiver = [[MCAddressBookDataReceiver alloc] initWithViewController:self andDelegate:self];
        [_personReceiver setTonightsBill:_tonightsBill];
    }
    [peoplePicker setPeoplePickerDelegate:_personReceiver];
    //    [peoplePicker setPredicateForSelectionOfPerson:nil];
    [peoplePicker setEdgesForExtendedLayout:UIRectEdgeNone];
    //    [[peoplePicker viewControllers][0] setEdgesForExtendedLayout:UIRectEdgeNone];
    [peoplePicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [[[peoplePicker navigationController] navigationBar] setBarStyle:UIBarStyleBlack];
    peoplePicker.navigationBar.translucent = NO;
    peoplePicker.navigationBar.opaque = YES;
    
    
    [[self navigationController] presentViewController:peoplePicker animated:YES completion:nil];
}

- (void)showContactsDisabledMessage
{
    NSString *title = NSLocalizedString(@"Access to contacts denied", @"Message to the user when access to the Contacts is denied by the user");
    NSString *message = NSLocalizedString(@"Go to your settings app and allow We all pay to access your contact data", @"Instructions for the user to go to the settings application and change the privacy settings for We all pay.");
    NSString *cancelButtonTitle = NSLocalizedString(@"Dismiss", @"Dismiss");
    NSString *settingsButtonTitle = NSLocalizedString(@"Go to settings", @"Title for a button that directs the user to the settings application.");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:settingsButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *settingsAppURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsAppURL];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:settingsAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)performFetchAndReloadTableView:(NSNotification *)notification
{
    UIManagedDocument *weAllPayDocument = [[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument];
    if ([weAllPayDocument documentState] == UIDocumentStateNormal) {
        [self performFetch];
        [[self tableView] reloadData];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self setEmptyMessageNow];
    }
}

- (void)performFetch
{
    NSError *error;
    BOOL success = [_dataController performFetch:&error];
    if (!success) {
        NSLog(@"Something went wrong: %@", error);
    }
}

- (void)setEmptyMessage
{
    if ([[_dataController fetchedObjects] count] != 0) {
        if ([[_emptyMessage bigMessage] alpha] > 0.0) {
            [UIView animateWithDuration:1.0 animations:^{
                [[_emptyMessage bigMessage] setAlpha:0.0];
                [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
            } completion:nil];
        }
    } else {
        if ([[_emptyMessage bigMessage] alpha] < 1.0) {
            [UIView animateWithDuration:1.0 animations:^{
                [[_emptyMessage bigMessage] setAlpha:1.0];
                [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            } completion:nil];
        }
    }
}

- (void)setEmptyMessageNow
{
    if ([[_dataController fetchedObjects] count] != 0) {
        [UIView animateWithDuration:0.0 animations:^{
            [[_emptyMessage bigMessage] setAlpha:0.0];
            [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        } completion:nil];
    } else {
        if ([[_emptyMessage bigMessage] alpha] < 1.0) {
            [UIView animateWithDuration:0.0 animations:^{
                [[_emptyMessage bigMessage] setAlpha:1.0];
                [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            } completion:nil];
        }
    }
}

- (void)showPaymentsHint
{
    if (_dataController.fetchedObjects.count > 0) {
        HintsController *controller = [[HintsController alloc] init];
        _paymentsHintsView.showHint = controller.showHints;
    } else {
        _paymentsHintsView.showHint = false;
    }
}

- (void)showPaymentsHintDelayed
{
    __weak typeof(self) weakSelf = self;
    int64_t delayInSeconds = 1.0;
    dispatch_time_t waitTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(waitTime, dispatch_get_main_queue(), ^{
        typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            [self showPaymentsHint];
        }
    });
}

#pragma mark - inherited from super

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    [self startRespondingToStoreChangeNotifications];
    
    _emptyMessage = [[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage" owner:self options:nil][0];
    [[_emptyMessage bigMessage] setText:NSLocalizedString(@"PEOPLE_LIST_EMPTY_MESSAGE", @"Press \"add Person\" to add a person who you'd like to share this bill with.")];
    if ([[_dataController fetchedObjects] count] > 0) {
        [[_emptyMessage bigMessage] setAlpha:0.0];
    }
    [[self tableView] setBackgroundView:_emptyMessage];
    [self showPaymentsHint];
    
    // Make sure a tap in the background dismisses the keyboard as well.
    UITapGestureRecognizer *thatTickles = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedInTheBackground:)];
    [thatTickles setCancelsTouchesInView:NO];
    [[self tableView] addGestureRecognizer:thatTickles];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_tripNameField setText:[_tonightsBill tripName]];
    [_tripNameField setDelegate:self];
    
    if (!_dataController) {
        _dataController = [[MCWeAllPayStoreController defaultStore] sharedBillPeoplePresentDataControllerForDelegate:self];
        [self performFetch];
        [[self tableView] reloadData];
    }
    
    BOOL shouldAppearAsEditing = [_myParent isChildTableViewEditing];
    [[self tableView] setEditing:shouldAppearAsEditing animated:NO];

    [self setEmptyMessageNow];
    
    HintsController *controller = [[HintsController alloc] init];
    if (_paymentsHintsView.showHint && !controller.showHints) {
        _paymentsHintsView.showHint = false;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([_tonightsBill tripName]) {
        [_tripNameField setPlaceholder:[[NSString alloc] initWithFormat:@"Enter something to rename %@", [_tonightsBill tripName]]];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _dataController = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)writeableTonightsBillIsCreated:(NSNotification *)notification
{
    // Should be executed on the background thread.
    NSDictionary *userInfo = [notification userInfo];
    _writableTonightsBill = [userInfo objectForKey:MCwritableTonightsBillKey];
    NSManagedObjectContext *mainContext = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
    NSManagedObjectID *tonightsBillID = [_writableTonightsBill objectID];
    [mainContext performBlock:^{
        _tonightsBill = (MCSharedBill *)[mainContext objectWithID:tonightsBillID];
    }];
    NSLog(@"PeoplePresent: WritableTonightsBillIsCreated has been executed.");
}

#pragma mark - UIViewController+WeAllPayStore notifications

- (void)storeWillBeSwapped:(NSNotification *)notification
{
    [super storeWillBeSwapped:notification];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[self view] setUserInteractionEnabled:NO];
    });
}

-(void)storeDidSwap:(NSNotification *)notification
{
    [super storeDidSwap:notification];
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (_dataController) {
            NSError *fetchError;
            if (![_dataController performFetch:&fetchError]) {
                NSLog(@"Error fetching: %@", fetchError);
            }
        }
        [[self tableView] reloadData];
        [self setEmptyMessage];
        [[self view] setUserInteractionEnabled:YES];
    });
}


#pragma mark - MCPersonViewChangeDelegate

- (void)sendDidSomethingChange:(BOOL)value
{
    if(!didSomethingChange && value) {
        didSomethingChange = YES;
    }
    [[self tableView] reloadData];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"Ok, in no people present message pressed.");
            break;
        case 1:
            NSLog(@"Edit, in no people present message pressed.");
            if (kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus() ||
                kABAuthorizationStatusNotDetermined == ABAddressBookGetAuthorizationStatus()) {
                [self addressBookButton:self];
            } else {
                [self addPersonButton:self];
            }
        default:
            break;
    }
}

#pragma mark - MCAddressBookReceiverDelegate

- (BOOL) isNewPersonFromAddressBookAlreadyPresent:(MCPerson *)newPerson
{
    return NO;
}

- (MCPerson *)personRecordToUse
{
    return nil;
}

- (void)receiveANewPersonFromAddressBook:(MCPerson *)newPerson
{
    didSomethingChange = YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [_tonightsBill setTripName:[_tripNameField text]];
    NSDate *now = [NSDate date];
    [_tonightsBill setDateModified:now];
    [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
    if (!didSomethingChange) {
        didSomethingChange = YES;
    }
    MCPerson *nextPayer = [[_tonightsBill fetchPeoplePresentOrderedByAmountPaid:YES] firstObject];

    WhoPayingUserDefaultsStoreInterface *groupStore = [[WhoPayingUserDefaultsStoreInterface alloc] initWithTonightsBillUUID:_tonightsBill.uniqueBillId tripName:_tonightsBill.tripName nextPayerUUID:nextPayer.uniquePersonId fullNameOfNextPayer:[nextPayer getFullName]];//[[WhoPayingUserDefaultsStoreInterface alloc] initWithTonightsBillUUID:_tonightsBill.uniqueBillId tripName:_tonightsBill.tripName nextPayerID:nextPayer.uniquePersonId fullNameOfNextPayer:[nextPayer getFullName]];
    [groupStore storeToDefaults];
    [[NCWidgetController widgetController] setHasContent:YES forWidgetWithBundleIdentifier:[WhoPayingUserDefaultsStoreInterface MCWhoIsPayingNextBundleIdentifier]];
}

#pragma mark - NSFetchedResultsControllerDelegat

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] endUpdates];
    [self showPaymentsHintDelayed];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self setEmptyMessage];
            break;
            
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self setEmptyMessage];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [[self tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            didSomethingChange = YES;
            break;
            
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_dataController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_dataController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPerson *thisCellsPerson = [_dataController objectAtIndexPath:indexPath];
    MCPersonTableViewCell *thisCell = [tableView dequeueReusableCellWithIdentifier:@"MCPersonTableViewCell"];
    
    [[thisCell personImage] setImage:[thisCellsPerson thumbnail]];
    [[thisCell nameLabel] setText:[thisCellsPerson getFullName]];
    [[thisCell emailLabel] setText:[thisCellsPerson defaultEmailAddress]];
    
    if (![thisCellsPerson hasPersonMadePaymentWithInvalidExchangeRates]) {
        [thisCell.fetchingExchangeRateIndicator stopAnimating];
        [[thisCell totalSpent] setHidden:NO];
        
        CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_tonightsBill.mainCurrency.code];
        thisCell.totalSpent.text = [cf stringForObjectValue:thisCellsPerson.totalSumPaid];
    } else {
        [thisCell.fetchingExchangeRateIndicator startAnimating];
        [[thisCell totalSpent] setHidden:YES];
    }

    
    return thisCell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self tableView] isEditing]) {
        MCPerson *person = [_dataController objectAtIndexPath:indexPath];
        if ([_tonightsBill hasPersonPaidSomething:person]) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MCPerson *removablePerson = [_dataController objectAtIndexPath:indexPath];
        [_tonightsBill deletePerson:removablePerson];
        [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
        didSomethingChange = YES;
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"openEditPerson" sender:self];
}

#pragma mark - UIStoryboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"openEditPerson"]) {
        id destination = [[segue destinationViewController] viewControllers][0];
        if ([destination conformsToProtocol:@protocol(MCTonightsBillTransfer)] && [destination conformsToProtocol:@protocol(MCThisPersonProtocol)]) {
            NSIndexPath *indexPathOfSelectedRow = [[self tableView] indexPathForSelectedRow];
            MCPerson *thePerson = [_dataController objectAtIndexPath:indexPathOfSelectedRow];
            [[MCWeAllPayStoreController defaultStore] beginUndoGroup];
            if (!thePerson) {
                // No person present create a new one.
                thePerson = [_tonightsBill addPerson];
                [thePerson setThumbnailDataFromImage:nil];
                [thePerson setPictureDataFromImage:nil];
                [destination setThisPerson:thePerson];
                [destination setIsNew:YES];
            } else {
                // Person present open it.
                [destination setThisPerson:thePerson];
                [destination setIsNew:NO];
            }
        } else {
            NSLog(@"%@: Unable to pass tonightsBill and thisPerson.", self);
        }

    }
}

@end
