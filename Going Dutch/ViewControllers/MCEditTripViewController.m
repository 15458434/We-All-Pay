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

@interface MCEditTripViewController ()

@end

@implementation MCEditTripViewController

@synthesize dismissOnDone;
@synthesize dismissOnCancel;

@synthesize tonightsBill;
@synthesize didSomethingChange;

@synthesize delegate;

# pragma mark - actions of this class

- (void)doneAddingPeople:(id)selector
{
    /*
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlockAndWait:^{
        [context processPendingChanges];
        [[context undoManager] disableUndoRegistration];
    }];
     */
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:dismissOnDone];
}

- (void)cancelNewTrip:(id)selector
{
    /*
    cancelPressed = YES;
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlock:^{
        [[context undoManager] disableUndoRegistration];
        if (didSomethingChange) {
            [[context undoManager] undoNestedGroup];
        }
        [MCSharedBill deleteSharedbill:tonightsBill];
    }];
     */
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:dismissOnCancel];
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

- (IBAction)addressBookButton:(id)sender {
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    if (!personReceiver) {
        personReceiver = [[MCAddressBookDataReceiver alloc] initWithViewController:self andDelegate:self];
        [personReceiver setTonightsBill:tonightsBill];
    }
    [peoplePicker setPeoplePickerDelegate:personReceiver];
    [peoplePicker setEdgesForExtendedLayout:UIRectEdgeNone];
    [[[peoplePicker viewControllers] objectAtIndex:0] setEdgesForExtendedLayout:UIRectEdgeNone];
    [peoplePicker setModalPresentationStyle:UIModalPresentationFormSheet];
    
    // Show adBanner on the iPhone not on the iPad.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [MCTools setAdBannerIfNotPaid:NO forViewController:[[peoplePicker viewControllers] objectAtIndex:0]];
    } else {
        [MCTools setAdBannerIfNotPaid:YES forViewController:[[peoplePicker viewControllers] objectAtIndex:0]];
    }
    [[self navigationController] presentViewController:peoplePicker animated:YES completion:nil];
}

- (IBAction)addPersonButton:(id)sender {
    /*
    MCPerson *newPerson = [MCPerson addPerson];
    [newPerson setThumbnailDataFromImage:nil];
    [newPerson setPictureDataFromImage:nil];
    [tonightsBill addPeoplePresentObject:newPerson];
    [self updateSubLabel];
    [doneButton setEnabled:YES];
    MCPersonViewController *pvc = [[MCPersonViewController alloc] initWithPerson:newPerson];
    [pvc setIsNew:YES];
    [pvc setTonightsBill:tonightsBill];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:pvc];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    }
    [[self navigationController] presentViewController:navController animated:YES completion:nil];
     */
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

- (void)updateMainLabel
{
    [[twoLabelTitleView mainLabel] setText:[tonightsBill tripName]];
}

- (void)updateSubLabel
{
    if ([[dataController fetchedObjects] count] == 1) {
        [[twoLabelTitleView subLabel] setText:[NSString stringWithFormat:@"%lu person present", (unsigned long)[[dataController fetchedObjects] count]]];
    } else {
        [[twoLabelTitleView subLabel] setText:[NSString stringWithFormat:@"%lu people present", (unsigned long)[[dataController fetchedObjects] count]]];
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
    
    [tripNameField setText:[tonightsBill tripName]];
    [tripNameField setDelegate:self];
    
    if (!twoLabelTitleView) {
        twoLabelTitleView = [[[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil] objectAtIndex:0];
        [[self navigationItem] setTitleView:twoLabelTitleView];
    }
    [[twoLabelTitleView mainLabel] setText:[tonightsBill tripName]];
    [self updateSubLabel];
    [[[self navigationItem] leftBarButtonItem] setEnabled:YES];
    
    //[[self navigationController] setToolbarHidden:NO animated:YES];
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
        [tripNameField setPlaceholder:@"Enter the activity of group."];
        [[twoLabelTitleView mainLabel] setText:@"New activity"];
        [[twoLabelTitleView subLabel] setText:@""];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[[self navigationItem] leftBarButtonItem] setEnabled:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([tonightsBill tripName]) {
        [tripNameField setPlaceholder:[[NSString alloc] initWithFormat:@"Enter something to rename %@", [tonightsBill tripName]]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [MCTools setAdBannerIfNotPaid:YES forViewController:self];
    
    if (!tonightsBill) {
        didSomethingChange = YES;
        tonightsBill = [MCSharedBill addSharedBill];
        [tripNameField setPlaceholder:@"Enter activity"];
    }
    
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
    
    [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
    [[[self navigationItem] leftBarButtonItem] setEnabled:YES];
    
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
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
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
    [self updateMainLabel];
    NSDate *nu = [NSDate date];
    [tonightsBill setDateModified:nu];
    if (!didSomethingChange) {
        didSomethingChange = YES;
        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    }
    if (isInitAsNew && !cancelPressed) {
        if (kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus() ||
            kABAuthorizationStatusNotDetermined == ABAddressBookGetAuthorizationStatus()) {
            [self addressBookButton:self];
        } else {
            [self addPersonButton:self];
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
            didSomethingChange = YES;
            [doneButton setEnabled:YES];
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
    [self performSegueWithIdentifier:@"openEditPerson" sender:self];
}

#pragma mark - UIStoryboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MCPerson *thePerson;
    if ([[[[segue destinationViewController] viewControllers] objectAtIndex:0] respondsToSelector:@selector(setChangeFlagDelegate:)]) {
        [[[[segue destinationViewController] viewControllers] objectAtIndex:0] setChangeFlagDelegate:self];
    }
    if ([[[[segue destinationViewController] viewControllers] objectAtIndex:0] respondsToSelector:@selector(setTonightsBill:)]) {
        [[[[segue destinationViewController] viewControllers] objectAtIndex:0] setTonightsBill:tonightsBill];
    }
    NSIndexPath *indexPathOfSelectedRow = [[self tableView] indexPathForSelectedRow];
    if (indexPathOfSelectedRow) {
        thePerson = [dataController objectAtIndexPath:indexPathOfSelectedRow];
        if ([[[[segue destinationViewController] viewControllers] objectAtIndex:0] respondsToSelector:@selector(setIsNew:)]) {
            [[[[segue destinationViewController] viewControllers] objectAtIndex:0] setIsNew:NO];
        }
    } else {
        if ([[[[segue destinationViewController] viewControllers] objectAtIndex:0] respondsToSelector:@selector(setIsNew:)]) {
            [[[[segue destinationViewController] viewControllers] objectAtIndex:0] setIsNew:YES];
        }
        [doneButton setEnabled:YES];
    }
    if ([[[[segue destinationViewController] viewControllers] objectAtIndex:0] respondsToSelector:@selector(setThisPerson:)]) {
        [[[[segue destinationViewController] viewControllers] objectAtIndex:0] setThisPerson:thePerson];
    }
    
}

@end
