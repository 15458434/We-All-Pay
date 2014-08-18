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

@synthesize didSomethingChange;

@synthesize delegate;

# pragma mark - actions of this class

- (IBAction)addressBookButton:(id)sender {
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    if (!personReceiver) {
        personReceiver = [[MCAddressBookDataReceiver alloc] initWithViewController:self andDelegate:self];
        [personReceiver setTonightsBill:_tonightsBill];
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
    
    [tripNameField setText:[_tonightsBill tripName]];
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
    
    if ([_tonightsBill tripName]) {
        [tripNameField setPlaceholder:[[NSString alloc] initWithFormat:@"Enter something to rename %@", [_tonightsBill tripName]]];
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
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [_tonightsBill setTripName:[tripNameField text]];
    NSDate *now = [NSDate date];
    [_tonightsBill setDateModified:now];
    [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
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
    [[thisCell totalSpent] setText:[nf stringFromNumber:[_tonightsBill totalSumPaidBy:thisCellsPerson]]];
    
    return thisCell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self tableView] isEditing]) {
        MCPerson *person = [dataController objectAtIndexPath:indexPath];
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
        MCPerson *removablePerson = [dataController objectAtIndexPath:indexPath];
        NSManagedObjectID *removablePersonID = [removablePerson objectID];
        NSManagedObjectContext *backgroundContext = [[MCWeAllPayStoreController defaultStore] backgroundThreadContext];
        [backgroundContext performBlock:^{
            if (![_writableTonightsBill hasPersonPaidSomething:removablePerson]) {
                MCPerson *removablePersonInBackgroundContext = (MCPerson *)[backgroundContext objectWithID:removablePersonID];
                [_writableTonightsBill deletePerson:removablePersonInBackgroundContext];
                [[MCWeAllPayStoreController defaultStore] savebackgroundContext];
            }
        }];
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
            MCPerson *thePerson = [dataController objectAtIndexPath:indexPathOfSelectedRow];
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
