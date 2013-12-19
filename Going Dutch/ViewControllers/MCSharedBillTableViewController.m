//
//  MCSharedBillTableViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBillTableViewController.h"

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"
#import "MCPayment+addons.h"

#import "MCAllTripsTableViewController.h"
#import "MCEditTripViewController.h"
#import "MCPaymentViewController.h"
#import "MCReturnPaymentViewController.h"

#import "MCPaymentTableViewCell.h"
#import "MCTwoLabelsTitleView.h"
#import "MCTextFieldAndLabelTitleView.h"

#import "MCReturnPayment.h"

@interface MCSharedBillTableViewController ()

@end

@implementation MCSharedBillTableViewController

@synthesize tonightsBill;
@synthesize didSomethingChange;

#pragma mark - Actions

- (IBAction)addPaymentButtonPressed:(id)sender {
    MCPaymentViewController *pvc = [[MCPaymentViewController alloc] initWithExistingPayment:nil fromBill:tonightsBill];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:pvc];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    }
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)editBillData:(id)sender
{
     MCEditTripViewController *tvc = [[MCEditTripViewController alloc] initWithBill:tonightsBill isNew:NO];
    [[self navigationController] pushViewController:tvc animated:YES];
}

- (void)showWhoPaysWho:(id)sender
{
    NSLog(@"%d", [tonightsBill doesEveryoneHaveAnEmailAddress]);
    MCReturnPaymentViewController *rpvc = [[MCReturnPaymentViewController alloc] initWithBill:tonightsBill];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rpvc];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    }
    [[self navigationController] presentViewController:navController animated:YES completion:nil];
}

- (void)openMailView:(id)sender;
{
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    [mailViewController setMailComposeDelegate:sender];
    [mailViewController setEdgesForExtendedLayout:UIRectEdgeNone];
    [mailViewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [[[mailViewController viewControllers] objectAtIndex:0] setEdgesForExtendedLayout:UIRectEdgeNone];
    NSArray *sda = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    NSArray *allPeople = [[tonightsBill peoplePresent] sortedArrayUsingDescriptors:sda];
    // Create a list of all email addresses
    NSMutableArray *listOfMailAddresses = [[NSMutableArray alloc] init];
    for (MCPerson *p in allPeople) {
        if ([p defaultEmailAddress]) {
            [listOfMailAddresses addObject:[p defaultEmailAddress]];
        }
    }
    // Set the mail header.
    [mailViewController setToRecipients:listOfMailAddresses];
    [mailViewController setSubject:[[NSString alloc] initWithFormat:@"Bill overview of our trip to %@.", [tonightsBill tripName]]];
    
    // Generate the text for the email.
    NSMutableString *mailBody = [[NSMutableString alloc] init];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [mailBody appendFormat:@"Dear %@\n", [tonightsBill stringOfApproxPeoplePresent]];
    [mailBody appendFormat:@"\n"];
    [mailBody appendFormat:@"From a total of %@, which was spend on our last trip to %@. We all have to pay an equal share of %@.\n", [nf stringFromNumber:[tonightsBill totalSumOfMoneyOfThisSharedBill]], [tonightsBill tripName], [nf stringFromNumber:[tonightsBill amountPeopleShouldHavePaid]]];
    [mailBody appendFormat:@"\n"];
    if ([tonightsBill totalAmountOfPeopleWhoHavePaid] == 0) {
        [mailBody appendFormat:@"Nobody has paid so far.\n"];
    } else if ([tonightsBill totalAmountOfPeopleWhoHavePaid] == 1) {
        [mailBody appendFormat:@"The person who has payed:\n"];
    } else {
        [mailBody appendFormat:@"The persons who have paid are:\n"];
    }
    NSArray * allPayments = [[tonightsBill payments] sortedArrayUsingDescriptors:sda];
    for (MCPayment *p in allPayments) {
        [mailBody appendFormat:@"%@ has paid %@ for %@.\n", [[p payingPerson] getName], [nf stringFromNumber:[p money]], [p descriptionOfPayment]];
    }
    [mailBody appendFormat:@"\n"];
    [mailBody appendFormat:@"To equalize and have everybody pay the average of %@, I suggest the following solution:\n", [nf stringFromNumber:[tonightsBill amountPeopleShouldHavePaid]]];
    for (MCReturnPayment *rp in [tonightsBill solveWhoHasToPayWhoFromThisBill]) {
        [mailBody appendFormat:@"%@\n", [rp stringForMail]];
    }
    [mailBody appendFormat:@"\n"];
    [mailBody appendFormat:@"If you have any remarks please let me know.\n"];
    [mailViewController setMessageBody:mailBody isHTML:NO];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [MCTools setAdBannerIfNotPaid:NO forViewController:[[mailViewController viewControllers] objectAtIndex:0]];
    } else {
        [MCTools setAdBannerIfNotPaid:YES forViewController:[[mailViewController viewControllers] objectAtIndex:0]];
    }
    if (sender!=self) {
        [sender presentViewController:mailViewController animated:YES completion:nil];
    } else {
        [[self navigationController] presentViewController:mailViewController animated:YES completion:nil];
    }
}

- (void)shareBill:(id)sender
{
    if ([tonightsBill doesEveryoneHaveAnEmailAddress]) {
        [self openMailView:sender];
    } else {
        NSLog(@"Not everyone has an email address");
        UIAlertView *mailAddressesMissing = [[UIAlertView alloc] initWithTitle:@"Unable to send email to all people."
                                                                       message:@"Reason: Not all people have a mail address."
                                                                      delegate:self
                                                             cancelButtonTitle:@"Cancel"
                                                             otherButtonTitles:@"Send anyway", @"Edit", nil];
        [mailAddressesMissing show];
    }
}

- (void)dismissEdit:(id)selector
{
    NSLog(@"Mis");
}

#pragma mark - New in this class.

/*
 - (id)initWithSharedBill:(MCSharedBill *)tBill
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        tonightsBill = tBill;
        [[self navigationItem] setTitle:[tBill tripName]];
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                    target:self
                                                                                    action:@selector(editBillData:)];
        [[self navigationItem] setRightBarButtonItem:editButton animated:YES];

    }
    return self;
}
*/

- (void)updateSubLabel
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [[twoLabelTitleView subLabel] setText:[NSString stringWithFormat:@"Total spent: %@", [nf stringFromNumber:[tonightsBill totalSumOfMoneyOfThisSharedBill]]]];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [[twoLabelTitleView mainLabel] setTextColor:[UIColor whiteColor]];
        [[twoLabelTitleView subLabel] setTextColor:[UIColor whiteColor]];
    }
}

- (void)updateToolbarButtons
{
    if ([[dataController fetchedObjects] count] > 0) {
        // enable mail and solve buttons.
        if (mailButton) {
            [mailButton setEnabled:YES];
        }
        if (returnPaymentButton) {
            [returnPaymentButton setEnabled:YES];
        }
    } else {
        // disable mail and solve buttons.
        if (mailButton) {
            [mailButton setEnabled:NO];
        }
        if (returnPaymentButton) {
            [returnPaymentButton setEnabled:NO];
        }
    }
}

#pragma mark - Inherited from super class.

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        [[self navigationController] setTitle:@"SharedBill"];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self
                                                                             action:@selector(addPayment:)];
        [[self navigationItem] setRightBarButtonItem:bbi animated:YES];
    }
    return self;
}

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
    
    [[self navigationItem] setTitle:[tonightsBill tripName]];
    
    // Load the custom titleView and add it to the screen.
    if (!twoLabelTitleView) {
        twoLabelTitleView = [[[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil] objectAtIndex:0];
        //[twoLabelTitleView setDelegate:self];
        //[[twoLabelTitleView mainLabel] addTarget:self action:@selector(dismissEdit:) forControlEvents:UIControlEventTouchUpOutside];
        [[self navigationItem] setTitleView:twoLabelTitleView];
    }
    [[twoLabelTitleView mainLabel] setText:[tonightsBill tripName]];
    
    [self updateSubLabel];
    [[self navigationItem] setTitleView:twoLabelTitleView];
    [[self navigationController] setToolbarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [MCTools setAdBannerIfNotPaid:YES forViewController:self];
    
    // Load nib for PaymentTableViewCell and register it to the TableView.
    UINib *nib = [UINib nibWithNibName:@"MCPaymentTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"MCPaymentTableViewCell"];
    
    if (!dataController) {
        // What entities will be fetched.
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPayment"];
        // How to sort the data.
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO];
        NSArray *sortDescriptorArray = [NSArray arrayWithObject:sortDescriptor];
        [request setSortDescriptors:sortDescriptorArray];
        // Select only people from tonightsBill.
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"onWhichBill = %@", tonightsBill];
        [request setPredicate:predicate];
        
        // Create the FetchedResultsController.
        dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext] sectionNameKeyPath:nil cacheName:[NSString stringWithFormat:@"All payments cache of trip: %@", [tonightsBill uniqueBillId]]];
        NSError *error;
        BOOL success = [dataController performFetch:&error];
        if (!success) {
            NSLog(@"Something went wrong fetching the payments");
        }
        [dataController setDelegate:self];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
    [context performBlock:^{
        [context processPendingChanges];
    }];
    
    [[self view] endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [[twoLabelTitleView mainLabel] setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    [[twoLabelTitleView mainLabel] setTextColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[twoLabelTitleView mainLabel] setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
    [[twoLabelTitleView mainLabel] setTextColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [tonightsBill setTripName:[[twoLabelTitleView mainLabel] text]];
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [textField setText:@""];
    return YES;
}

#pragma mark - MCPaymentViewControllerDelegate
/*
- (void)removePayment:(MCPayment *)payment fromPaymentViewController:(MCPaymentViewController *)pvc
{
    [tonightsBill removePayment:payment];
    [[self tableView] reloadData];
}
 */

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"Cancel button pressed");
            break;
        case 1:
            [self openMailView:self];
            break;
        case 2:
            [self editBillData:self];
            break;
        default:
            break;
    }
}

#pragma mark - MFMailViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultCancelled) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    } else if (result == MFMailComposeResultSent) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    } else if (result == MFMailComposeResultSaved) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSLog(@"Something went wrong: %@", [error localizedDescription]);
    }
}
    
#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] endUpdates];
    [self updateSubLabel];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
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
    [self updateToolbarButtons];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[dataController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[dataController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPayment *thisCellsPayment = [dataController objectAtIndexPath:indexPath];
    MCPaymentTableViewCell *paymentCell = [tableView dequeueReusableCellWithIdentifier:@"MCPaymentTableViewCell"];
    
    [[paymentCell namePayerLabel] setText:[NSString stringWithFormat:@"%@ paid", [[thisCellsPayment payingPerson] getFullName]]];
    [[paymentCell pictureOfPayer] setImage:[[thisCellsPayment payingPerson] thumbnail]];
    [[paymentCell whatPaidLabel] setText:[NSString stringWithFormat:@"for %@", [thisCellsPayment descriptionOfPayment]]];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [[paymentCell moneyPaidLabel] setText:[nf stringFromNumber:[thisCellsPayment money]]];
    
    return paymentCell;
    /*
    // Check to see if an unused cell is available if not make a new one.
    static NSString *CellIdentifier = @"TableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    // Get payment and put it's description in the cell.
    MCPayment *thisCellsPayment = [[tonightsBill allPayments] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[thisCellsPayment description]];
    
    return cell;*/
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MCPayment *toBeDeletedPayment = [dataController objectAtIndexPath:indexPath];
        [MCPayment deletePayment:toBeDeletedPayment];
        [[[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext] processPendingChanges];
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
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPaymentViewController *pvc = [[MCPaymentViewController alloc] initWithExistingPayment:[dataController objectAtIndexPath:indexPath] fromBill:tonightsBill];
    [pvc setDelegate:self];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:pvc];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    }
    [[self navigationController] presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Storyboard stuff

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[[[segue destinationViewController] viewControllers] objectAtIndex:0] respondsToSelector:@selector(setTonightsBill:)]) {
        [[[[segue destinationViewController] viewControllers] objectAtIndex:0] setTonightsBill:tonightsBill];
    }
    if ([[[[segue destinationViewController] viewControllers] objectAtIndex:0] respondsToSelector:@selector(setSendMailObject:)]) {
        [[[[segue destinationViewController] viewControllers] objectAtIndex:0] setSendMailObject:self];
    }
}

@end
