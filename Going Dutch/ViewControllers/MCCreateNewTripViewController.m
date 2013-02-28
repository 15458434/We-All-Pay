//
//  MCPeopleViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 25-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCCreateNewTripViewController.h"
#import "MCPeople.h"
#import "MCPerson.h"
#import "MCSharedBill.h"
#import "MCPersonViewController.h"
#import "MCAllTripsStore.h"
#import "MCPersonViewController.h"
#import "MCPersonTableViewCell.h"

@interface MCCreateNewTripViewController ()

@end

@implementation MCCreateNewTripViewController

@synthesize dismissblock;
@synthesize dismissYourSelf;

@synthesize tonightsBill;


# pragma mark - actions of this class

- (void)addPerson:(id)selector
{
    MCPerson *newPerson = [[MCPerson alloc] init];
    [[tonightsBill people] addPerson:newPerson];
    MCPersonViewController *pvc = [[MCPersonViewController alloc] initWithPerson:newPerson];
    [[self navigationController] pushViewController:pvc animated:YES];
    NSInteger lastRow = [[[tonightsBill people] allPeople] indexOfObject:newPerson];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
    [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)doneAddingPeople:(id)selector
{
    if ([[tonightsBill people] areTherePeople]) {
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:dismissblock];
    }
}

- (void)doneEditingTrip:(id)selector
{
    if ([[tonightsBill people] areTherePeople]) {
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void)cancelNewTrip:(id)selector
{
    [[MCAllTripsStore sharedList] removeTrip:tonightsBill];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:dismissYourSelf];
}

- (void)cancelEditTrip:(id)selector
{
    NSLog(@"Cancel Edit Trip pressed");
}

- (void)getPeopleFromAddressBook:(id)selector
{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    [peoplePicker setPeoplePickerDelegate:self];
    [self presentViewController:peoplePicker animated:YES completion:nil];
}

- (IBAction)changeNameOfTrip:(id)sender {
    [tonightsBill setTripName:[tripNameField text]];
    [[self view] endEditing:YES];
}

- (IBAction)dismissKeyboard:(id)sender {
    [tonightsBill setTripName:[tripNameField text]];
    [[self view] endEditing:YES];
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
        UIBarButtonItem *bbi;
        if (isNew) {
            bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                target:self
                                                                action:@selector(doneAddingPeople:)];
            [[self navigationItem] setTitle:@"New bill data"];
            [[self navigationItem] setLeftBarButtonItem:bbi animated:YES];
            bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                target:self
                                                                action:@selector(cancelNewTrip:)];
            [[self navigationItem] setRightBarButtonItem:bbi];
        } else {
            bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                target:self
                                                                action:@selector(doneEditingTrip:)];
            [[self navigationItem] setTitle:[tonightsBill tripName]];
            bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                target:self
                                                                action:@selector(cancelEditTrip:)];
        }

        [tripNameField setDelegate:self];
    }
    return self;
}

- (void)getPersonData:(ABRecordRef)person
{
    MCPerson *newPerson = [[MCPerson alloc] init];
    [newPerson setThumbnail:[UIImage imageWithData:(__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail)]];
    [newPerson setPicture:[UIImage imageWithData:(__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize)]];
    [newPerson setName:(__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty)];
    ABMultiValueRef emailAddresses = ABRecordCopyValue(person, kABPersonEmailProperty);
    if (ABMultiValueGetCount(emailAddresses)) {
        NSMutableArray *allEmailAddresses= [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < ABMultiValueGetCount(emailAddresses); i++) {
            NSString *emailAddressForArray=(__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailAddresses, i);
            [allEmailAddresses addObject:emailAddressForArray];
            [newPerson setAllEmailAddressesFromAddressBook:allEmailAddresses];
        }
        [newPerson setEmailAddress:(__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailAddresses, 0)];
    } else {
        [newPerson setEmailAddress:nil];
    }
    CFRelease(emailAddresses);
    [[tonightsBill people] addPerson:newPerson];
    NSInteger rowOfNewPerson = [[[tonightsBill people] allPeople] indexOfObject:newPerson];
    NSIndexPath *indexPathOfNewPerson = [NSIndexPath indexPathForRow:rowOfNewPerson inSection:0];
    [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPathOfNewPerson] withRowAnimation:UITableViewRowAnimationTop];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
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
{    [super viewWillDisappear:animated];
    
    [[self view] endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *addressBookButton;
    if (kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus()) {
        addressBookButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                                                            target:self
                                                            action:@selector(getPeopleFromAddressBook:)];
    } else {
        addressBookButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                            target:self
                                                            action:@selector(addPerson:)];
    }
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:self
                                                                                action:nil];
    NSArray *toolBarButtons = [[NSArray alloc] initWithObjects:flexButton, addressBookButton, nil];
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

#pragma mark - ABPeoplePickerNavigationControllerDelegate>

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [self getPersonData:person];
    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([[[tonightsBill people] allPeople] count] == 0) {
        if (kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus()) {
            [self getPeopleFromAddressBook:self];
        } else {
            [self addPerson:self];
        }
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [tonightsBill setTripName:[textField text]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[tonightsBill people] allPeople] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPerson *thisCellsPerson = [[[tonightsBill people] allPeople] objectAtIndex:[indexPath row]];
    MCPersonTableViewCell *thisCell = [tableView dequeueReusableCellWithIdentifier:@"MCPersonTableViewCell"];
    
    [[thisCell personImage] setImage:[thisCellsPerson thumbnail]];
    [[thisCell nameLabel] setText:[thisCellsPerson name]];
    [[thisCell emailLabel] setText:[thisCellsPerson emailAddress]];
    
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
    MCPerson *person = [[[tonightsBill people] allPeople] objectAtIndex:[indexPath row]];
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
        MCPerson *removablePerson = [[[tonightsBill people] allPeople] objectAtIndex:[indexPath row]];
        if (![tonightsBill hasPersonPaidSomething:removablePerson]) {
            [tonightsBill removePerson:removablePerson];
            NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
            [[self tableView] deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
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
    MCPerson *selectedPerson = [[[tonightsBill people] allPeople] objectAtIndex:[indexPath row]];
    MCPersonViewController *pvc = [[MCPersonViewController alloc] initWithPerson:selectedPerson];
    [[self navigationController] pushViewController:pvc animated:YES];
}

@end
