//
//  MCPeopleViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 25-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import FirebaseAnalytics;

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

@property (weak, nonatomic) IBOutlet UITextField *tripNameField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet MCTwoLabelsTitleView *twoLabelTitleView;

@property (strong, nonatomic) MCTableEmptyMessage *emptyMessage;

@property (nonatomic, strong) NSFetchedResultsController *dataController;
@property (nonatomic, strong) ContactsDataReceiver *contactsInserter;

@property (nonatomic) BOOL cancelPressed;

@end

@implementation MCEditTripViewController

#pragma mark - actions of this class

- (IBAction)addressBookButton:(id)sender {
    [FIRAnalytics logEventWithName:@"Contacts pressed" parameters:nil];
    if (!_contactsInserter) {
        _contactsInserter = [[ContactsDataReceiver alloc] initWith:_tonightsBill];
    }
    [_contactsInserter presentContactsPickerWith:self completion:nil];
}


- (IBAction)addPersonButton:(id)sender {
    [FIRAnalytics logEventWithName:@"Add Person pressed" parameters:nil];
    if ([_tripNameField isEditing]) {
        [_tripNameField resignFirstResponder];
    }
}

- (void)tappedInTheBackground:(id)sender
{
    [FIRAnalytics logEventWithName:@"Background tapped" parameters:nil];
    [_tripNameField resignFirstResponder];
}

#pragma mark - new in this class.

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
                [[self.emptyMessage bigMessage] setAlpha:0.0];
                [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
            } completion:nil];
        }
    } else {
        if ([[_emptyMessage bigMessage] alpha] < 1.0) {
            [UIView animateWithDuration:1.0 animations:^{
                [[self.emptyMessage bigMessage] setAlpha:1.0];
                [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            } completion:nil];
        }
    }
}

- (void)setEmptyMessageNow
{
    if ([[_dataController fetchedObjects] count] != 0) {
        [UIView animateWithDuration:0.0 animations:^{
            [[self->_emptyMessage bigMessage] setAlpha:0.0];
            [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        } completion:nil];
    } else {
        if ([[_emptyMessage bigMessage] alpha] < 1.0) {
            [UIView animateWithDuration:0.0 animations:^{
                [[self->_emptyMessage bigMessage] setAlpha:1.0];
                [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            } completion:nil];
        }
    }
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

- (void)dealloc
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
        self->_tonightsBill = (MCSharedBill *)[mainContext objectWithID:tonightsBillID];
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
        if (self->_dataController) {
            NSError *fetchError;
            if (![self->_dataController performFetch:&fetchError]) {
                NSLog(@"Error fetching: %@", fetchError);
            }
        }
        [[self tableView] reloadData];
        [self setEmptyMessage];
        [[self view] setUserInteractionEnabled:YES];
    });
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:_tripNameField]) {
        [FIRAnalytics logEventWithName:@"Did begin editing event name" parameters:nil];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:_tripNameField]) {
        [FIRAnalytics logEventWithName:@"Did end editing event name" parameters:nil];
    }
    [_tonightsBill setTripName:[_tripNameField text]];
    NSDate *now = [NSDate date];
    [_tonightsBill setDateModified:now];
    [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
    if (!_didSomethingChange) {
        _didSomethingChange = YES;
    }
    MCPerson *nextPayer = [[_tonightsBill fetchPeoplePresentOrderedByAmountPaid:YES] firstObject];

    WhoPayingUserDefaultsStoreInterface *groupStore = [[WhoPayingUserDefaultsStoreInterface alloc] initWithTonightsBillUUID:_tonightsBill.uniqueBillId tripName:_tonightsBill.tripName nextPayerUUID:nextPayer.uniquePersonId fullNameOfNextPayer:[nextPayer getFullName]];
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
            _didSomethingChange = YES;
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
        [FIRAnalytics logEventWithName:@"Delete Person" parameters:nil];
        MCPerson *removablePerson = [_dataController objectAtIndexPath:indexPath];
        [_tonightsBill deletePerson:removablePerson];
        [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
        _didSomethingChange = YES;
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
    [FIRAnalytics logEventWithName:@"Open person details" parameters:nil];
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
    
    NSIndexPath *indexPathForSelectedRow = [self.tableView indexPathForSelectedRow];
    if (indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:indexPathForSelectedRow animated:YES];
    }
}

@end
