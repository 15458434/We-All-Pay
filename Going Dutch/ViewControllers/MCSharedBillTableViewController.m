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

#import "MCPaymentTableViewCell.h"
#import "MCTwoLabelsTitleView.h"
#import "MCTextFieldAndLabelTitleView.h"

@interface MCSharedBillTableViewController ()

@end

@implementation MCSharedBillTableViewController

@synthesize tonightsBill;
@synthesize didSomethingChange;

#pragma mark - Actions

- (void)addPayment:(id)sender
{
    MCPaymentViewController *pvc = [[MCPaymentViewController alloc] initWithExistingPayment:nil fromBill:tonightsBill];
    [[self navigationController] pushViewController:pvc animated:YES];
}

- (void)editBillData:(id)sender
{
     MCEditTripViewController *tvc = [[MCEditTripViewController alloc] initWithBill:tonightsBill isNew:NO];
    [[self navigationController] pushViewController:tvc animated:YES];
}

- (void)showWhoPaysWho:(id)sender
{
    /*NSLog(@"%d", [[tonightsBill people] doesEveryoneHaveAMailAddress]);
    MCReturnPaymentViewController *rpvc = [[MCReturnPaymentViewController alloc] initWithBill:tonightsBill];
    [[self navigationController] pushViewController:rpvc animated:YES];
     */
}

- (void)shareBill:(id)sender
{
    /*
    if ([[tonightsBill people] doesEveryoneHaveAMailAddress]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        [mailViewController setMailComposeDelegate:self];
        NSArray *allPeople = [[tonightsBill people] allPeople];
        // Create a list of all email addresses
        NSMutableArray *listOfMailAddresses = [[NSMutableArray alloc] init];
        for (MCPerson *p in allPeople) {
            [listOfMailAddresses addObject:[p emailAddress]];
        }
        // Set the mail header.
        [mailViewController setToRecipients:listOfMailAddresses];
        [mailViewController setSubject:[[NSString alloc] initWithFormat:@"Bill overview of our trip to %@.", [tonightsBill tripName]]];
        
        // Generate the text for the email.
        NSMutableString *mailBody = [[NSMutableString alloc] init];
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
        [mailBody appendFormat:@"Dear %@\n", [[tonightsBill people] stringOfApproxPeoplePresent]];
        [mailBody appendFormat:@"\n"];
        [mailBody appendFormat:@"From a total of %@, which was spend on our last trip to %@. We all have to pay an equal share of %@.\n", [nf stringFromNumber:[[NSNumber alloc] initWithDouble:[tonightsBill totalSumOfMoneyOfThisSharedBill]]], [tonightsBill tripName], [nf stringFromNumber:[[NSNumber alloc] initWithDouble:[tonightsBill amountPeopleShouldHavePaid]]]];
        [mailBody appendFormat:@"\n"];
        if ([tonightsBill totalAmountOfPeopleWhoHavePaid] == 0) {
            [mailBody appendFormat:@"Nobody has paid so far.\n"];
        } else if ([tonightsBill totalAmountOfPeopleWhoHavePaid] == 1) {
            [mailBody appendFormat:@"The person who has payed:\n"];
        } else {
            [mailBody appendFormat:@"The persons who have paid are:\n"];
        }
        for (MCPayment *p in [tonightsBill allPayments]) {
            [mailBody appendFormat:@"%@ has paid %@ for %@.\n", [[p payingPerson] firstName], [nf stringFromNumber:[[NSNumber alloc] initWithDouble:[p money]]], [p place]];
        }
        [mailBody appendFormat:@"\n"];
        [mailBody appendFormat:@"To equalize and have everybody pay the average of %@, I suggest the following solution:\n", [nf stringFromNumber:[[NSNumber alloc] initWithDouble:[tonightsBill amountPeopleShouldHavePaid]]]];
        for (MCReturnPayment *rp in [tonightsBill solveWhoHasToPayWhoFromThisBill]) {
            [mailBody appendFormat:@"%@\n", [rp description]];
        }
        [mailBody appendFormat:@"\n"];
        [mailBody appendFormat:@"If you have any remarks please let me know.\n"];
        [mailViewController setMessageBody:mailBody isHTML:NO];
        [self presentViewController:mailViewController animated:YES completion:nil];
    } else {
        NSLog(@"Not everyone has an email address");
        UIAlertView *mailAddressesMissing = [[UIAlertView alloc] initWithTitle:@"Unable to send email to all people."
                                                                       message:@"Reason: Not all people have a mail address."
                                                                      delegate:self
                                                             cancelButtonTitle:@"Cancel"
                                                             otherButtonTitles:@"Edit", nil];
        [mailAddressesMissing show];
    }*/
}

- (void)dismissEdit:(id)selector
{
    NSLog(@"Mis");
}

#pragma mark - New in this class.

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

- (void)updateSubLabel
{
    /*
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [[twoLabelTitleView subLabel] setText:[NSString stringWithFormat:@"Total spent: %@", [nf stringFromNumber:[NSNumber numberWithDouble:[tonightsBill totalSumOfMoneyOfThisSharedBill]]]]];
    */
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
        dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext] sectionNameKeyPath:nil cacheName:@"All payments cache"];
        NSError *error;
        BOOL success = [dataController performFetch:&error];
        if (!success) {
            NSLog(@"Something went wrong fetching the payments");
        }
        [dataController setDelegate:self];
    }
    
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
    
    [[self navigationController] setToolbarHidden:NO animated:YES];
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mail icon"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(shareBill:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addPayment:)];
    UIBarButtonItem *solveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar is sign"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(showWhoPaysWho:)];
    NSArray *bottomButtonArray;
    if ([MFMailComposeViewController canSendMail]) {
        bottomButtonArray = [[NSArray alloc] initWithObjects:shareButton, flexibleSpace, solveButton, flexibleSpace, addButton, nil];
    } else {
        bottomButtonArray = [[NSArray alloc] initWithObjects:flexibleSpace, solveButton, flexibleSpace, addButton, nil];
    }
    [self setToolbarItems:bottomButtonArray animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load nib for PaymentTableViewCell and register it to the TableView.
    UINib *nib = [UINib nibWithNibName:@"MCPaymentTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"MCPaymentTableViewCell"];
    
    // if there are NO people on this SharedBill go to the people addscreen
    if (![tonightsBill areTherePeople]) {
        NSLog(@"No people present.");
        MCEditTripViewController *pvc = [[MCEditTripViewController alloc] initWithBill:tonightsBill isNew:YES];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:pvc];
        [pvc setDismissblock:^{
            [[self tableView] reloadData];
            [[self navigationItem] setTitle:[tonightsBill tripName]];
        }];
        [pvc setDismissYourSelf:^{
            [[self navigationController] popViewControllerAnimated:YES];
        }];
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext];
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
            [self editBillData:self];
        default:
            break;
    }
}

#pragma mark - MFMailViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    /*
    if (result == MFMailComposeResultCancelled) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    } else if (result == MFMailComposeResultSent) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    } else if (result == MFMailComposeResultSaved) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSLog(@"Something went wrong: %@", [error localizedDescription]);
    }
     */
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
            [[self tableView] cellForRowAtIndexPath:indexPath];
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
    return [[[dataController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPayment *thisCellsPayment = [dataController objectAtIndexPath:indexPath];
    MCPaymentTableViewCell *paymentCell = [tableView dequeueReusableCellWithIdentifier:@"MCPaymentTableViewCell"];
    
    [[paymentCell namePayerLabel] setText:[[thisCellsPayment payingPerson] getFullName]];
    [[paymentCell pictureOfPayer] setImage:[[thisCellsPayment payingPerson] thumbnail]];
    [[paymentCell whatPaidLabel] setText:[thisCellsPayment descriptionOfPayment]];
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
        [[[[MCWeAllPayStoreController sharedStore] weAllPayStoreDocument] managedObjectContext] processPendingChanges];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPaymentViewController *pvc = [[MCPaymentViewController alloc] initWithExistingPayment:[dataController objectAtIndexPath:indexPath] fromBill:tonightsBill];
    [pvc setDelegate:self];
    [[self navigationController] pushViewController:pvc animated:YES];
}

@end
