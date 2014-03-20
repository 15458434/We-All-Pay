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
#import "MCSharedBillPageViewController.h"

#import "MCPaymentTableViewCell.h"
#import "MCTwoLabelsTitleView.h"
#import "MCTableEmptyMessage.h"

#import "MCReturnPayment.h"

@interface MCSharedBillTableViewController ()

@end

@implementation MCSharedBillTableViewController

@synthesize tonightsBill;
@synthesize didSomethingChange;
@synthesize delegate;
@synthesize mailDelegate;

#pragma mark - Actions

- (IBAction)mailButtonPressed:(id)sender
{
    //[self shareBill:self];
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

- (void)dismissEdit:(id)selector
{
    NSLog(@"Mis");
}

#pragma mark - New in this class.

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

- (void)prepareDataControllerAndFetch
{
    // What entities will be fetched.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPayment"];
    [request setRelationshipKeyPathsForPrefetching:@[ @"payingPerson" ]];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    // Load nib for PaymentTableViewCell and register it to the TableView.
    UINib *nib = [UINib nibWithNibName:@"MCPaymentTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"MCPaymentTableViewCell"];
    
    emptyMessage = [[[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage" owner:self options:nil] objectAtIndex:0];
    [[self tableView] setBackgroundView:emptyMessage];
    [[emptyMessage bigMessage] setText:NSLocalizedString(@"EMPTY_PAYMENT_LIST_MESSAGE", @"Press \"add payment\" to add a payment to this event.")];
    [[emptyMessage bigMessage] setTextColor:[UIColor lightGrayColor]];
    [emptyMessage setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setToolbarHidden:YES animated:YES];
    
    if (!dataController) {
        [self prepareDataControllerAndFetch];
        [[self tableView] reloadData];
    }
    if ([[dataController fetchedObjects] count] > 0) {
        [[emptyMessage bigMessage] setAlpha:0.0];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[self view] endEditing:YES];
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

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{

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
    //[self updateSubLabel];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            [self setEmptyMessage];
            break;
            
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
            [self setEmptyMessage];
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
    return [[[dataController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPayment *thisCellsPayment = [dataController objectAtIndexPath:indexPath];
    if (!thisCellsPayment) {
    }
    MCPaymentTableViewCell *paymentCell = [tableView dequeueReusableCellWithIdentifier:@"MCPaymentTableViewCell"];
    
    NSString *thisCellsPayerName;
    if ([thisCellsPayment payingPerson]) {
        thisCellsPayerName = [[thisCellsPayment payingPerson] getFullName];
    } else {
        thisCellsPayerName = NSLocalizedString(@"THISPAYMENTCELL_NOPAYERNAME", @"Someone");
    }
    [[paymentCell namePayerLabel] setText:[NSString stringWithFormat:@"%@%@", thisCellsPayerName, NSLocalizedString(@"PAYMENTCELL_PAYERNAME_EXTRA", @" paid") ]];
    [[paymentCell pictureOfPayer] setImage:[[thisCellsPayment payingPerson] thumbnail]];
    
    NSString *thisCellsDescriptionOfPayment = [thisCellsPayment descriptionOfPayment];
    if (!thisCellsDescriptionOfPayment) {
        thisCellsDescriptionOfPayment = NSLocalizedString(@"THISPAYMENTCELL_NOOBJECT", @"Something");
    }
    [[paymentCell whatPaidLabel] setText:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"PAYMENT_CELL_PAIDFOR_EXTRA", @"for ") , thisCellsDescriptionOfPayment]];
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

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self tableView] isEditing]) {
        return YES;
    } else {
        return NO;
    }
}

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
    [self performSegueWithIdentifier:@"openPaymentView" sender:self];
}

#pragma mark - Storyboard stuff

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[[[segue destinationViewController] viewControllers] objectAtIndex:0] respondsToSelector:@selector(setTonightsBill:)]) {
        [[[[segue destinationViewController] viewControllers] objectAtIndex:0] setTonightsBill:tonightsBill];
    }
    if ([[[[segue destinationViewController] viewControllers] objectAtIndex:0] respondsToSelector:@selector(setSendMailObject:)]) {
        [[[[segue destinationViewController] viewControllers] objectAtIndex:0] setSendMailObject:[self mailDelegate]];
    }

    if ([[[[segue destinationViewController] viewControllers] objectAtIndex:0] respondsToSelector:@selector(setThisPayment:)]) {
        MCPayment *thePayment;
        NSIndexPath *indexPathOfSelectedRow = [[self tableView] indexPathForSelectedRow];
        if (indexPathOfSelectedRow) {
            thePayment = [dataController objectAtIndexPath:indexPathOfSelectedRow];
        }
        if ([[[[segue destinationViewController] viewControllers] objectAtIndex:0] respondsToSelector:@selector(setIsNew:)]) {
            if (thePayment) {
                [[[[segue destinationViewController] viewControllers] objectAtIndex:0] setIsNew:YES];
            } else {
                [[[[segue destinationViewController] viewControllers] objectAtIndex:0] setIsNew:NO];
            }
        }
        [[[[segue destinationViewController] viewControllers] objectAtIndex:0] setThisPayment:thePayment];
        [[[[segue destinationViewController] viewControllers] objectAtIndex:0] setDelegate:self];
    }
}

@end
