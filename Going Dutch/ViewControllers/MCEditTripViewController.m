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

#import "MCWeAllPayStoreController.h"
#import "MCPerson+addons.h"
#import "MCSharedBill+addons.h"

#import "MCPersonTableViewCell.h"
#import "MCTwoLabelsTitleView.h"
#import "MCTableEmptyMessage.h"

@interface MCEditTripViewController ()

@end

@implementation MCEditTripViewController

@synthesize dismissOnDone;
@synthesize dismissOnCancel;

@synthesize tonightsBill;
@synthesize didSomethingChange;

@synthesize delegate;

# pragma mark - actions of this class

- (IBAction)addressBookButton:(id)sender {
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    if (!personReceiver) {
        personReceiver = [[MCAddressBookDataReceiver alloc] initWithViewController:self andDelegate:self];
        [personReceiver setTonightsBill:tonightsBill];
    }
    [peoplePicker setPeoplePickerDelegate:personReceiver];
    [peoplePicker setEdgesForExtendedLayout:UIRectEdgeNone];
    [[peoplePicker viewControllers][0] setEdgesForExtendedLayout:UIRectEdgeNone];
    [peoplePicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [[[peoplePicker navigationController] navigationBar] setBarStyle:UIBarStyleBlack];
    
    [[self navigationController] presentViewController:peoplePicker animated:YES completion:nil];
}

- (IBAction)addPersonButton:(id)sender {
    if ([tripNameField isEditing]) {
        [tripNameField resignFirstResponder];
    }
}

- (IBAction)cancelButtonPressed:(id)sender {
    cancelPressed = YES;
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlockAndWait:^{
        [[context undoManager] disableUndoRegistration];
        if (didSomethingChange) {
            [[context undoManager] undoNestedGroup];
        }
    }];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonPressed:(id)sender {
    if ([tonightsBill areTherePeople]) {
        NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
        [context performBlockAndWait:^{
            [context processPendingChanges];
            [[context undoManager] disableUndoRegistration];
        }];
        [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIAlertView *noPeoplePresentMessage = [[UIAlertView alloc] initWithTitle:@"No people present on this bill."
                                                                         message:@"Please add the people who you'd like to share this bill with."
                                                                        delegate:self
                                                               cancelButtonTitle:@"Cancel"
                                                               otherButtonTitles:@"Edit", nil];
        [noPeoplePresentMessage show];
    }
}

#pragma mark - new in this class.

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
    BOOL success = [dataController performFetch:&error];
    if (!success) {
        NSLog(@"Something went wrong");
    }
}

- (void)setEmptyMessage
{
    if (![[dataController fetchedObjects] count] == 0) {
        if ([[emptyMessage bigMessage] alpha] > 0.0) {
            [UIView animateWithDuration:1.0 animations:^{
                [[emptyMessage bigMessage] setAlpha:0.0];
                [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
            } completion:nil];
        }
    } else {
        if ([[emptyMessage bigMessage] alpha] < 1.0) {
            [UIView animateWithDuration:1.0 animations:^{
                [[emptyMessage bigMessage] setAlpha:1.0];
                [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            } completion:nil];
        }
    }
}

- (void)setEmptyMessageNow
{
    if (![[dataController fetchedObjects] count] == 0) {
        [UIView animateWithDuration:0.0 animations:^{
            [[emptyMessage bigMessage] setAlpha:0.0];
            [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        } completion:nil];
    } else {
        if ([[emptyMessage bigMessage] alpha] < 1.0) {
            [UIView animateWithDuration:0.0 animations:^{
                [[emptyMessage bigMessage] setAlpha:1.0];
                [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            } completion:nil];
        }
    }
}


#pragma mark - inherited from super

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    if (!tonightsBill) {
        didSomethingChange = YES;
        tonightsBill = [MCSharedBill addSharedBill];
        [tripNameField setPlaceholder:@"Enter activity"];
    }
    
    // Load and register Nib to the tableView for use.
    UINib *nib = [UINib nibWithNibName:@"MCPersonTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"MCPersonTableViewCell"];
    
    emptyMessage = [[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage" owner:self options:nil][0];
    [[emptyMessage bigMessage] setText:NSLocalizedString(@"PEOPLE_LIST_EMPTY_MESSAGE", @"Press \"add Person\" to add a person who you'd like to share this bill with.")];
    if ([[dataController fetchedObjects] count] > 0) {
        [[emptyMessage bigMessage] setAlpha:0.0];
    }
    [[self tableView] setBackgroundView:emptyMessage];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [tripNameField setText:[tonightsBill tripName]];
    [tripNameField setDelegate:self];
    
    if (!dataController) {
        dataController = [[MCWeAllPayStoreController defaultStore] sharedBillPeoplePresentDataControllerForDelegate:self];
    }
    UIManagedDocument *weAllPayDocument = [[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument];
    if (![[MCWeAllPayStoreController defaultStore] isDocumentStateNormal]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performFetchAndReloadTableView:) name:UIDocumentStateChangedNotification object:weAllPayDocument];
    } else {
        [self performFetch];
        [[self tableView] reloadData];
        [self setEmptyMessageNow];
    }
    
    if (kABAuthorizationStatusDenied == ABAddressBookGetAuthorizationStatus()) {
        [addressBookButton setAlpha:0.0];
        CGRect addPersonButtonRect = [addPersonButton frame];
        CGRect viewBounds = [[[self tableView] tableHeaderView] bounds];
        CGPoint newPosition = CGPointMake( (viewBounds.size.width / 2.0) - (addPersonButtonRect.size.width / 2.0), addPersonButtonRect.origin.y);
        addPersonButtonRect.origin = newPosition;
        [addPersonButton setFrame:addPersonButtonRect];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([tonightsBill tripName]) {
        [tripNameField setPlaceholder:[[NSString alloc] initWithFormat:@"Enter something to rename %@", [tonightsBill tripName]]];
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"MCPeoplePresentTableView_iPhone"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    dataController = nil;
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

#pragma mark - MCPersonViewChangeDelegate

- (void)sendDidSomethingChange:(BOOL)value
{
    if(!didSomethingChange && value) {
        didSomethingChange = YES;
        // [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
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
    //return [editedPeople isPersonPresent:newPerson];
    return NO;
}

- (MCPerson *)personRecordToUse
{
    return nil;
}

- (void)receiveANewPersonFromAddressBook:(MCPerson *)newPerson
{
    didSomethingChange = YES;
    //[[[self navigationItem] rightBarButtonItem] setEnabled:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [tonightsBill setTripName:[textField text]];
    NSDate *nu = [NSDate date];
    [tonightsBill setDateModified:nu];
    if (!didSomethingChange) {
        didSomethingChange = YES;
    }
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
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            [self setEmptyMessage];
            break;
            
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            [self setEmptyMessage];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [[self tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            didSomethingChange = YES;
            break;
            
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[dataController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    return [[dataController sections][section] numberOfObjects];
    return [[dataController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPerson *thisCellsPerson = [dataController objectAtIndexPath:indexPath];
    MCPersonTableViewCell *thisCell = [tableView dequeueReusableCellWithIdentifier:@"MCPersonTableViewCell"];
    
    [[thisCell personImage] setImage:[thisCellsPerson thumbnail]];
    if ([thisCellsPerson thumbnail]) {
        [thisCell setCircularImage:[thisCellsPerson thumbnail]];
    }
    [[thisCell nameLabel] setText:[thisCellsPerson getFullName]];
    [[thisCell emailLabel] setText:[thisCellsPerson defaultEmailAddress]];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [[thisCell totalSpent] setText:[nf stringFromNumber:[tonightsBill totalSumPaidBy:thisCellsPerson]]];
    
    return thisCell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self tableView] isEditing]) {
        MCPerson *person = [dataController objectAtIndexPath:indexPath];
        if ([tonightsBill hasPersonPaidSomething:person]) {
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
        MCPerson *removablePerson = [dataController objectAtIndexPath:indexPath];
        if (![tonightsBill hasPersonPaidSomething:removablePerson]) {
            NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
            [context deleteObject:removablePerson];
            //[self updateSubLabel];
            didSomethingChange = YES;
            //[[[self navigationItem] rightBarButtonItem];
        }
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
    MCPerson *thePerson;
    if ([[[segue destinationViewController] viewControllers][0] respondsToSelector:@selector(setChangeFlagDelegate:)]) {
        [[[segue destinationViewController] viewControllers][0] setChangeFlagDelegate:self];
    }
    if ([[[segue destinationViewController] viewControllers][0] respondsToSelector:@selector(setTonightsBill:)]) {
        [[[segue destinationViewController] viewControllers][0] setTonightsBill:tonightsBill];
    }
    NSIndexPath *indexPathOfSelectedRow = [[self tableView] indexPathForSelectedRow];
    if (indexPathOfSelectedRow) {
        thePerson = [dataController objectAtIndexPath:indexPathOfSelectedRow];
        if ([[[segue destinationViewController] viewControllers][0] respondsToSelector:@selector(setIsNew:)]) {
            [[[segue destinationViewController] viewControllers][0] setIsNew:NO];
        }
    } else {
        if ([[[segue destinationViewController] viewControllers][0] respondsToSelector:@selector(setIsNew:)]) {
            [[[segue destinationViewController] viewControllers][0] setIsNew:YES];
        }
        [doneButton setEnabled:YES];
    }
    if ([[[segue destinationViewController] viewControllers][0] respondsToSelector:@selector(setThisPerson:)]) {
        [[[segue destinationViewController] viewControllers][0] setThisPerson:thePerson];
    }
    
}

@end
