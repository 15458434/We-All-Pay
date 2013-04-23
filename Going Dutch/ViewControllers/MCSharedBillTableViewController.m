//
//  MCSharedBillTableViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBillTableViewController.h"
#import "MCSharedBill.h"
#import "MCPayment.h"
#import "MCAllTripsTableViewController.h"
#import "MCEditTripViewController.h"
#import "MCAllTripsStore.h"
#import "MCReturnPaymentViewController.h"
#import "MCPaymentTableViewCell.h"
#import "MCPerson.h"
#import "MCPeople.h"
#import "MCReturnPayment.h"

@interface MCSharedBillTableViewController ()

@end

@implementation MCSharedBillTableViewController

@synthesize tonightsBill;
@synthesize didSomethingChange;

#pragma mark - Actions

- (void)addPayment:(id)sender
{
    MCPaymentViewController *pvc = [[MCPaymentViewController alloc] initWithExistingPayment:nil fromBill:tonightsBill];
    [pvc setDelegate:self];
    [[self navigationController] pushViewController:pvc animated:YES];
}

- (void)editBillData:(id)sender
{
    MCEditTripViewController *tvc = [[MCEditTripViewController alloc] initWithBill:tonightsBill isNew:NO];
    [[self navigationController] pushViewController:tvc animated:YES];
}

- (void)showWhoPaysWho:(id)sender
{
    NSLog(@"%d", [[tonightsBill people] doesEveryoneHaveAMailAddress]);
    MCReturnPaymentViewController *rpvc = [[MCReturnPaymentViewController alloc] initWithBill:tonightsBill];
    [[self navigationController] pushViewController:rpvc animated:YES];
}

- (void)shareBill:(id)sender
{
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
        [mailBody appendFormat:@"The persons who have paid are:\n"];
        for (MCPayment *p in [tonightsBill allPayments]) {
            [mailBody appendFormat:@"%@ has paid %@ for %@.\n", [[p payingPerson] firstName], [nf stringFromNumber:[[NSNumber alloc] initWithDouble:[p money]]], [p place]];
        }
        [mailBody appendFormat:@"\n"];
        [mailBody appendFormat:@"To equalize and have everybody pay the average of %@, I'd suggest the following solution:\n", [nf stringFromNumber:[[NSNumber alloc] initWithDouble:[tonightsBill amountPeopleShouldHavePaid]]]];
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
    }
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

#pragma mark - Inherited from super class.

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        tonightsBill = [[MCSharedBill alloc] initWithTestGroup];
        [[self navigationController] setTitle:@"Test"];
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
    [[self tableView] reloadData];
    [[self navigationItem] setTitle:[tonightsBill tripName]];
    
    [[self navigationController] setToolbarHidden:NO animated:YES];
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                 target:self
                                                                                 action:@selector(shareBill:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addPayment:)];
    UIBarButtonItem *solveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
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
        MCEditTripViewController *pvc = [[MCEditTripViewController alloc] initWithBill:tonightsBill isNew:YES];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:pvc];
        [pvc setDismissblock:^{
            [[self tableView] reloadData];
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
    
    [[self view] endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MCPaymentViewControllerDelegate

- (void)removePayment:(MCPayment *)payment fromPaymentViewController:(MCPaymentViewController *)pvc
{
    if (![pvc didSomethingChange]) {
        [tonightsBill removePayment:payment];
        [[self tableView] reloadData];
    }
}

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[tonightsBill allPayments] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPayment *thisCellsPayment = [[tonightsBill allPayments] objectAtIndex:[indexPath row]];
    MCPaymentTableViewCell *paymentCell = [tableView dequeueReusableCellWithIdentifier:@"MCPaymentTableViewCell"];
    
    MCPerson *thisCellsPayer = [thisCellsPayment payingPerson];
    [[paymentCell namePayerLabel] setText:[thisCellsPayer getFullName]];
    [[paymentCell pictureOfPayer] setImage:[thisCellsPayer thumbnail]];
    [[paymentCell whatPaidLabel] setText:[thisCellsPayment place]];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSNumber *thisCellsMoney = [[NSNumber alloc] initWithDouble:[thisCellsPayment money]];
    [[paymentCell moneyPaidLabel] setText:[nf stringFromNumber:thisCellsMoney]];
    
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
        MCPayment *toBeDeletedPayment = [[tonightsBill allPayments] objectAtIndex:[indexPath row]];
        [tonightsBill removePayment:toBeDeletedPayment];
    }
    [[self tableView] reloadData];
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
    MCPaymentViewController *pvc = [[MCPaymentViewController alloc] initWithExistingPayment:[[tonightsBill allPayments] objectAtIndex:[indexPath row]] fromBill:tonightsBill];
    [[self navigationController] pushViewController:pvc animated:YES];
}

@end
