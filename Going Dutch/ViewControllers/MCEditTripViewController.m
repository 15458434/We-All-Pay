//
//  MCPeopleViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 25-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCEditTripViewController.h"
#import "MCPeople.h"
#import "MCPerson.h"
#import "MCSharedBill.h"
#import "MCPersonViewController.h"
#import "MCAllTripsStore.h"
#import "MCPersonTableViewCell.h"
#import "MCTwoLabelsTitleView.h"

@interface MCEditTripViewController ()

@end

@implementation MCEditTripViewController

@synthesize dismissblock;
@synthesize dismissYourSelf;

@synthesize tonightsBill;
@synthesize didSomethingChange;


# pragma mark - actions of this class

- (void)addPerson:(id)selector
{
    MCPerson *newPerson = [[MCPerson alloc] init];
    [editedPeople addPerson:newPerson];
    [self updateSubLabel];
    MCPersonViewController *pvc = [[MCPersonViewController alloc] initWithPerson:newPerson];
    [pvc setIsNew:YES];
    [[self navigationController] pushViewController:pvc animated:YES];
    NSInteger lastRow = [[editedPeople allPeople] indexOfObject:newPerson];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
    [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)doneAddingPeople:(id)selector
{
    if ([editedPeople areTherePeople]) {
        [tonightsBill setTripName:tripName];
        [editedPeople setEditing:NO];
        [tonightsBill setPeople:editedPeople];
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:dismissblock];
    }
}

- (void)doneEditingTrip:(id)selector
{
    if ([editedPeople areTherePeople]) {
        if (tripName) {
            [tonightsBill setTripName:tripName];
        }
        [editedPeople setEditing:NO];
        [tonightsBill setPeople:editedPeople];
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
    [[MCAllTripsStore sharedList] removeTrip:tonightsBill];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:dismissYourSelf];
}

- (void)cancelEditTrip:(id)selector
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)getPeopleFromAddressBook:(id)selector
{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    if (!personReceiver) {
        personReceiver = [[MCAddressBookDataReceiver alloc] initWithViewController:self andDelegate:self];
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
    [tonightsBill setTripName:[tripNameField text]];
    [[self view] endEditing:YES];
}

#pragma mark - new in this class.

- (void)setTonightsBill:(MCSharedBill *)tBill
{
    tonightsBill = tBill;
    editedPeople = [[tonightsBill people] copy];
    [editedPeople setEditing:YES];
}

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
            editedPeople = [[tonightsBill people] copy];
            [editedPeople setEditing:YES];
        } else {
            @throw [NSException exceptionWithName:@"Nil"
                                           reason:@"Tonightsbill not allowed to be nil"
                                         userInfo:nil];
        }
        isInitAsNew = isNew;
        didSomethingChange = NO;
        [tripNameField setDelegate:self];
    }
    return self;
}

- (void)updateSubLabel
{
    if ([tonightsBill totalAmountOfPeople] == 1) {
        [[twoLabelTitleView subLabel] setText:[NSString stringWithFormat:@"%d person present", [editedPeople howManyPeople]]];
    } else {
        [[twoLabelTitleView subLabel] setText:[NSString stringWithFormat:@"%d people present", [editedPeople howManyPeople]]];
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
    
    if (!twoLabelTitleView) {
        twoLabelTitleView = [[[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil] objectAtIndex:0];
        [[self navigationItem] setTitleView:twoLabelTitleView];
    }
    [[twoLabelTitleView mainLabel] setText:[tonightsBill tripName]];
    [self updateSubLabel];
    [[[self navigationItem] leftBarButtonItem] setEnabled:YES];
    
    [[self navigationController] setToolbarHidden:NO animated:YES];
    [[self view] endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
    [[[self navigationItem] leftBarButtonItem] setEnabled:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!isInitAsNew) {
        [tripNameField setPlaceholder:[[NSString alloc] initWithFormat:@"Enter something to rename %@.", [tonightsBill tripName]]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    return [editedPeople isPersonPresent:newPerson];
}

- (void)receiveANewPersonFromAddressBook:(MCPerson *)newPerson
{
    NSUInteger rowNumber = [editedPeople addPerson:newPerson];
    NSIndexPath *ip = [NSIndexPath indexPathForItem:rowNumber inSection:0];
    [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationTop];
    didSomethingChange = YES;
    [personReceiver setEditedPerson:nil];
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([[editedPeople allPeople] count] == 0) {
        if (kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus() ||
            kABAuthorizationStatusNotDetermined == ABAddressBookGetAuthorizationStatus()) {
            [self getPeopleFromAddressBook:self];
        } else {
            [self addPerson:self];
        }
    }
    didSomethingChange = YES;
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    tripName = [[NSString alloc] initWithString:[textField text]];
    if (!didSomethingChange) {
        didSomethingChange = YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[editedPeople allPeople] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPerson *thisCellsPerson = [[editedPeople allPeople] objectAtIndex:[indexPath row]];
    MCPersonTableViewCell *thisCell = [tableView dequeueReusableCellWithIdentifier:@"MCPersonTableViewCell"];
    
    [[thisCell personImage] setImage:[thisCellsPerson thumbnail]];
    [[thisCell nameLabel] setText:[thisCellsPerson getFullName]];
    [[thisCell emailLabel] setText:[thisCellsPerson emailAddress]];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [[thisCell totalSpent] setText:[nf stringFromNumber:[NSNumber numberWithDouble:[tonightsBill totalSumPaidBy:thisCellsPerson]]]];
    
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
    MCPerson *person = [[editedPeople allPeople] objectAtIndex:[indexPath row]];
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
        MCPerson *removablePerson = [[editedPeople allPeople] objectAtIndex:[indexPath row]];
        if (![tonightsBill hasPersonPaidSomething:removablePerson]) {
            [editedPeople removePerson:removablePerson];
            [self updateSubLabel];
            NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
            [[self tableView] deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
            didSomethingChange = YES;
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
    MCPerson *selectedPerson = [[editedPeople allPeople] objectAtIndex:[indexPath row]];
    MCPersonViewController *pvc = [[MCPersonViewController alloc] initWithPerson:selectedPerson];
    [pvc setTonightsBill:tonightsBill];
    [pvc setChangeFlagDelegate:self];
    [pvc setIsNew:NO];
    [[self navigationController] pushViewController:pvc animated:YES];
}

@end
