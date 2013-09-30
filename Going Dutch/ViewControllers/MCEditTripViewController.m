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

#import "MCWeAllPayStoreController.h"
#import "MCPerson+addons.h"
#import "MCSharedBill+addons.h"
#import "MCPersonTableViewCell.h"
#import "MCTwoLabelsTitleView.h"

@interface MCEditTripViewController ()

@end

@implementation MCEditTripViewController

@synthesize dismissOnDone;
@synthesize dismissOnCancel;

@synthesize tonightsBill;
@synthesize didSomethingChange;


# pragma mark - actions of this class

- (void)addPerson:(id)selector
{
    MCPerson *newPerson = [MCPerson addPerson];
    [tonightsBill addPeoplePresentObject:newPerson];
    [self updateSubLabel];
    [doneButton setEnabled:YES];
    MCPersonViewController *pvc = [[MCPersonViewController alloc] initWithPerson:newPerson];
    [pvc setIsNew:YES];
    [pvc setTonightsBill:tonightsBill];
    [[self navigationController] pushViewController:pvc animated:YES];
}

- (void)doneAddingPeople:(id)selector
{
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlock:^{
        [context processPendingChanges];
    }];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:dismissOnDone];
}

- (void)doneEditingTrip:(id)selector
{
    if ([tonightsBill areTherePeople]) {
        NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
        [context performBlockAndWait:^{
            [context processPendingChanges];
        }];
        [[self navigationController] popViewControllerAnimated:YES];
    } else {
        UIAlertView *noPeoplePresentMessage = [[UIAlertView alloc] initWithTitle:@"No people present on this bill."
                                                                         message:@"Please add the people who you'd like to share this bill with."
                                                                        delegate:self
                                                               cancelButtonTitle:@"Cancel"
                                                               otherButtonTitles:@"Edit", nil];
        [noPeoplePresentMessage show];
    }
}

- (void)cancelNewTrip:(id)selector
{
    cancelPressed = YES;
    // [MCSharedBill deleteSharedbill:tonightsBill];
    // tonightsBill = nil;
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:dismissOnCancel];
}

- (void)cancelEditTrip:(id)selector
{
    cancelPressed = YES;
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)getPeopleFromAddressBook:(id)selector
{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    if (!personReceiver) {
        personReceiver = [[MCAddressBookDataReceiver alloc] initWithViewController:self andDelegate:self];
        [personReceiver setTonightsBill:tonightsBill];
    }
    [peoplePicker setPeoplePickerDelegate:personReceiver];
    [self presentViewController:peoplePicker animated:YES completion:nil];
}

- (IBAction)changeNameOfTrip:(id)sender {
    [tonightsBill setTripName:[tripNameField text]];
    [[self view] endEditing:YES];
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
}

- (IBAction)dismissKeyboard:(id)sender {
    /*
    [tonightsBill setTripName:[tripNameField text]];
    [[self view] endEditing:YES];
     */
}

#pragma mark - new in this class.

- (UIView *)NewTripHeaderView
{
    if (!newTripHeaderView) {
        [[NSBundle mainBundle] loadNibNamed:@"NewTripHeaderView" owner:self options:nil];
    }
    return newTripHeaderView;
}

- (id)initWithBill:(MCSharedBill *)newBill isNew:(BOOL)isNew
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        if (newBill) {
            tonightsBill = newBill;
        } else {
            @throw [NSException exceptionWithName:@"Nil"
                                           reason:@"Tonightsbill not allowed to be nil"
                                         userInfo:nil];
        }
        isInitAsNew = isNew;
        cancelPressed = NO;
        didSomethingChange = NO;
    }
    return self;
}

- (void)updateSubLabel
{
    if ([[dataController fetchedObjects] count] == 1) {
        [[twoLabelTitleView subLabel] setText:[NSString stringWithFormat:@"%d person present", [[dataController fetchedObjects] count]]];
    } else {
        [[twoLabelTitleView subLabel] setText:[NSString stringWithFormat:@"%d people present", [[dataController fetchedObjects] count]]];
    }
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [[twoLabelTitleView mainLabel] setTextColor:[UIColor whiteColor]];
        [[twoLabelTitleView subLabel] setTextColor:[UIColor whiteColor]];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [tripNameField setDelegate:self];
    
    if (!twoLabelTitleView) {
        twoLabelTitleView = [[[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil] objectAtIndex:0];
        [[self navigationItem] setTitleView:twoLabelTitleView];
    }
    [[twoLabelTitleView mainLabel] setText:[tonightsBill tripName]];
    [self updateSubLabel];
    [[[self navigationItem] leftBarButtonItem] setEnabled:YES];
    
    [[self navigationController] setToolbarHidden:NO animated:YES];
    [[self view] endEditing:YES];
    
    if (!dataController) {
        // What entities will be fetched.
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
        // How to sort the data.
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO];
        NSArray *sortDescriptorArray = [NSArray arrayWithObject:sortDescriptor];
        [request setSortDescriptors:sortDescriptorArray];
        // Select only people from tonightsBill.
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sharedBill = %@", tonightsBill];
        [request setPredicate:predicate];
        
        // Create the FetchedResultsController.
        dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext] sectionNameKeyPath:nil cacheName:@"All persons cache."];
        [dataController setDelegate:self];
        NSError *error;
        BOOL success = [dataController performFetch:&error];
        if (!success) {
            NSLog(@"Something went wrong");
        }
    }
    
    if (isInitAsNew && [[dataController fetchedObjects] count] == 0) {
        [doneButton setEnabled:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    //[[[self navigationItem] rightBarButtonItem] setEnabled:NO];
    [[[self navigationItem] leftBarButtonItem] setEnabled:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!isInitAsNew) {
        [tripNameField setPlaceholder:[[NSString alloc] initWithFormat:@"Enter something to rename %@.", [tonightsBill tripName]]];
    } else if ([[dataController fetchedObjects] count] == 0){
        [tripNameField becomeFirstResponder];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setCanDisplayBannerAds:YES];
    
    if (!dataController) {
        // What entities will be fetched.
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
        // How to sort the data.
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO];
        NSArray *sortDescriptorArray = [NSArray arrayWithObject:sortDescriptor];
        [request setSortDescriptors:sortDescriptorArray];
        // Select only people from tonightsBill.
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY sharedBill = %@", tonightsBill];
        [request setPredicate:predicate];
        
        // Create the FetchedResultsController.
        
        dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext] sectionNameKeyPath:nil cacheName:[NSString stringWithFormat:@"All persons cache of trip: %@", [tonightsBill uniqueBillId]]];
        [dataController setDelegate:self];
        NSError *error;
        BOOL success = [dataController performFetch:&error];
        if (!success) {
            NSLog(@"Something went wrong");
        }
    }
    
    if (isInitAsNew) {
        doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                   target:self
                                                                   action:@selector(doneAddingPeople:)];
        [[self navigationItem] setTitle:@"New bill data"];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                             target:self
                                                                             action:@selector(cancelNewTrip:)];
        [[self navigationItem] setLeftBarButtonItem:bbi];
    } else {
        doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                   target:self
                                                                   action:@selector(doneEditingTrip:)];
        [[self navigationItem] setTitle:[tonightsBill tripName]];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                             target:self
                                                                             action:@selector(cancelEditTrip:)];
        [[self navigationItem] setLeftBarButtonItem:bbi];
    }
    [[self navigationItem] setRightBarButtonItem:doneButton];
    [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
    [[[self navigationItem] leftBarButtonItem] setEnabled:YES];
    
    UIBarButtonItem *addPersonButton;
    if (kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus() ||
        kABAuthorizationStatusNotDetermined == ABAddressBookGetAuthorizationStatus()) {
        addPersonButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                                                            target:self
                                                            action:@selector(getPeopleFromAddressBook:)];
    } else {
        addPersonButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                            target:self
                                                            action:@selector(addPerson:)];
    }
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:self
                                                                                action:nil];
    NSArray *toolBarButtons = [[NSArray alloc] initWithObjects:flexButton, addPersonButton, nil];
    [self setToolbarItems:toolBarButtons animated:YES];
    
    // Load and register Nib to the tableView for use.
    UINib *nib = [UINib nibWithNibName:@"MCPersonTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"MCPersonTableViewCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MCPersonViewChangeDelegate

- (void)sendDidSomethingChange:(BOOL)value
{
    if(!didSomethingChange && value) {
        didSomethingChange = YES;
        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
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
                [self getPeopleFromAddressBook:self];
            } else {
                [self addPerson:self];
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

- (void)receiveANewPersonFromAddressBook:(MCPerson *)newPerson
{
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlock:^{
        NSError *error;
        [[[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext] save:&error];
        if (error) {
            NSLog(@"Unable to store or something.");
        }
        didSomethingChange = YES;
        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    }];
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
    if (!didSomethingChange) {
        didSomethingChange = YES;
        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    }
    if (isInitAsNew && !cancelPressed) {
        if (kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus() ||
            kABAuthorizationStatusNotDetermined == ABAddressBookGetAuthorizationStatus()) {
            [self getPeopleFromAddressBook:self];
        } else {
            [self addPerson:self];
        }
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
            [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            [self updateSubLabel];
            break;
            
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            [self updateSubLabel];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
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
    return [[[dataController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPerson *thisCellsPerson = [dataController objectAtIndexPath:indexPath];
    MCPersonTableViewCell *thisCell = [tableView dequeueReusableCellWithIdentifier:@"MCPersonTableViewCell"];
    
    [[thisCell personImage] setImage:[thisCellsPerson thumbnail]];
    [[thisCell nameLabel] setText:[thisCellsPerson getFullName]];
    [[thisCell emailLabel] setText:[thisCellsPerson defaultEmailAddress]];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [[thisCell totalSpent] setText:[nf stringFromNumber:[tonightsBill totalSumPaidBy:thisCellsPerson]]];
    
    return thisCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self NewTripHeaderView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [[self NewTripHeaderView] bounds].size.height;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPerson *person = [dataController objectAtIndexPath:indexPath];
    if ([tonightsBill hasPersonPaidSomething:person]) {
        return NO;
    } else {
        return YES;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MCPerson *removablePerson = [dataController objectAtIndexPath:indexPath];
        if (![tonightsBill hasPersonPaidSomething:removablePerson]) {
            NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
            [context performBlock:^{
                [context deleteObject:removablePerson];
                [self updateSubLabel];
                didSomethingChange = YES;
                [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
            }];
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
    MCPerson *selectedPerson = [dataController objectAtIndexPath:indexPath];
    MCPersonViewController *pvc = [[MCPersonViewController alloc] initWithPerson:selectedPerson];
    [pvc setTonightsBill:tonightsBill];
    [pvc setChangeFlagDelegate:self];
    [pvc setIsNew:NO];
    [[self navigationController] pushViewController:pvc animated:YES];
}

@end
