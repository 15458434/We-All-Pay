//
//  MCSharedBillTableViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBillTableViewController.h"
#import "UIViewController+WeAllPayStore.h"

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"
#import "MCPayment+addons.h"

#import "MCAllTripsTableViewController.h"
#import "MCEditTripViewController.h"
#import "MCPaymentViewController.h"
#import "MCReturnPaymentViewController.h"
#import "MCSharedBillPageViewController.h"

#import "MCReturnPayment.h"

#import "MCCategoryPictureStoreController.h"
#import "MCCategoryPictureObject.h"

#import "MCWhoPayingUserDefaultsStoreInterface+WeAllPay.h"

#import "We_all_pay-Swift.h"

@interface MCSharedBillTableViewController ()

@property (nonatomic, strong) NSFetchedResultsController *dataController;
@property (nonatomic, strong) UIAlertView *payerMissingAlertView;

@end

@implementation MCSharedBillTableViewController

@synthesize didSomethingChange;
@synthesize delegate;
@synthesize mailDelegate;

#pragma mark - Actions

- (IBAction)solveButtonPressed:(id)sender {
    // Check for all payers present.
    if ([_tonightsBill doAllPaymentHaveAPayer]) {
        // perform segue
        [self performSegueWithIdentifier:@"solveButton" sender:self];
    } else {
        // Give user alert.
        NSString *title = NSLocalizedString(@"UNABLE_TO_SOLVE", @"Unable to solve");
        NSString *message = NSLocalizedString(@"At least one of the payments is missing a payer.", @"One of the payments is missing a payer.");
        NSString *cancelButtonTitle = NSLocalizedString(@"CANCEL", @"Cancel");
        NSString *fixItButtonTitle = NSLocalizedString(@"Go to", @"Go to");
        _payerMissingAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:fixItButtonTitle, nil];
        [_payerMissingAlertView show];
    }
}

- (void)showWhoPaysWho:(id)sender
{
    NSLog(@"%d", [_tonightsBill doesEveryoneHaveAnEmailAddress]);
    MCReturnPaymentViewController *rpvc = [[MCReturnPaymentViewController alloc] initWithBill:_tonightsBill];
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
    [[twoLabelTitleView subLabel] setText:[NSString stringWithFormat:@"Total spent: %@", [nf stringFromNumber:[_tonightsBill totalSumOfMoneyOfThisSharedBill]]]];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [[twoLabelTitleView mainLabel] setTextColor:[UIColor whiteColor]];
        [[twoLabelTitleView subLabel] setTextColor:[UIColor whiteColor]];
    }
}

- (void)prepareDataControllerAndFetch
{
    // TODO: Replace this with the NSFetchedResultsController coming from MCWeAllPayStoreController.
    _dataController = [[MCWeAllPayStoreController defaultStore] sharedBillPaymentsDataControllerForDelegate:self];
    NSError *error;
    BOOL success = [_dataController performFetch:&error];
    if (!success) {
        NSLog(@"Something went wrong fetching the payments");
    }
}

- (void)setEmptyMessage
{
    if (![[_dataController fetchedObjects] count] == 0) {
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

- (void)openFirstPaymentWithoutAPayer
{
    // This opens the payment detail view with the first payment on the tonightsBill which, doesn't have a payer.
    [self performSegueWithIdentifier:@"openFirstPaymentWithoutPayer" sender:self];
}

#pragma mark - Inherited from super class.

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        [[self navigationController] setTitle:@"SharedBill"];
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
    
    [self startRespondingToStoreChangeNotifications];
    
    emptyMessage = [[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage" owner:self options:nil][0];
    [[self tableView] setBackgroundView:emptyMessage];
    [[emptyMessage bigMessage] setText:NSLocalizedString(@"EMPTY_PAYMENT_LIST_MESSAGE", @"Press \"add payment\" to add a payment to this event.")];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setToolbarHidden:YES animated:YES];
    
    if (!_dataController) {
        [self prepareDataControllerAndFetch];
        [[self tableView] reloadData];
    }
    if ([[_dataController fetchedObjects] count] > 0) {
        [[emptyMessage bigMessage] setAlpha:0.0];
    } else {
        [[emptyMessage bigMessage] setAlpha:1.0];
    }
    
    BOOL shouldAppearAsEditing = [_myParent isChildTableViewEditing];
    [[self tableView] setEditing:shouldAppearAsEditing animated:NO];
    
    // Don't show payment swipe hint anymore.
    HintsController *controller = [[HintsController alloc] init];
    controller.showHints = false;
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
    
    _dataController = nil;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController+WeAllPayStore notifications

- (void)storeWillBeSwapped:(NSNotification *)notification
{
    [super storeWillBeSwapped:notification];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[self view] setUserInteractionEnabled:NO];
    });
}

-(void)storeDidSwap:(NSNotification *)notification
{
    [super storeDidSwap:notification];
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (_dataController) {
            NSError *fetchError;
            if (![_dataController performFetch:&fetchError]) {
                NSLog(@"Error fetching: %@", fetchError);
            }
        }
        [[self tableView] reloadData];
        [self setEmptyMessage];
        [[self view] setUserInteractionEnabled:YES];
    });
}


#pragma mark - NSNotification

- (void)writableTonightsBillIsCreated:(NSNotification *)notification
{
    // Should be executed on the background thread.
    NSDictionary *userInfo = [notification userInfo];
    _writableTonightsBill = [userInfo objectForKey:MCwritableTonightsBillKey];
    NSLog(@"WritableTonightsBillIsCreated has been executed.");
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _payerMissingAlertView) {
        switch (buttonIndex) {
            case 0:
                // Cancel button.
                NSLog(@"Cancel pressed: I'm not doing anything.");
                break;
            case 1:
                // Go To button.
                // Open first payment with missing payer.
                [self openFirstPaymentWithoutAPayer];
                break;
            default:
                break;
        }
    }
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
    [_tonightsBill setTripName:[[twoLabelTitleView mainLabel] text]];
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [textField setText:@""];
    return YES;
}

#pragma mark - MFMailViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultCancelled) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    } else if (result == MFMailComposeResultSent) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
        [[NCWidgetController widgetController] setHasContent:NO forWidgetWithBundleIdentifier:MCWhoIsPayingNextBundleIdentifier];
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
    return [[_dataController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_dataController sections][section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPayment *thisCellsPayment = [_dataController objectAtIndexPath:indexPath];
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
    
    // Get category picture.
    NSArray *pictureObjects = [[MCCategoryPictureStoreController sharedController] pictureObjects];
    MCCategoryPictureObject *categoryObject = pictureObjects[[[thisCellsPayment categoryId] shortValue]];
    paymentCell.pictureOfPayer.image = [categoryObject smallPicture];
    
    NSString *thisCellsDescriptionOfPayment = [thisCellsPayment descriptionOfPayment];
    if (!thisCellsDescriptionOfPayment) {
        thisCellsDescriptionOfPayment = NSLocalizedString(@"THISPAYMENTCELL_NOOBJECT", @"Something");
    }
    [[paymentCell whatPaidLabel] setText:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"PAYMENT_CELL_PAIDFOR_EXTRA", @"for ") , thisCellsDescriptionOfPayment]];
    paymentCell.moneyPaidLabel.text = [thisCellsPayment getMoneyValueInCurrencyAsAString];
    
    return paymentCell;
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
        MCPayment *toBeDeletedPayment = [_dataController objectAtIndexPath:indexPath];
        [MCPayment deletePayment:toBeDeletedPayment];
        [MCWhoPayingUserDefaultsStoreInterface sendToUserDefaultsStoreInterface:_tonightsBill];
        [[[MCWeAllPayStoreController defaultStore] mainThreadContext] processPendingChanges];
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
    [self performSegueWithIdentifier:@"openPaymentView" sender:self];
}

#pragma mark - Storyboard stuff

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"openFirstPaymentWithoutPayer"]) {
        NSParameterAssert([[[segue destinationViewController] viewControllers][0] conformsToProtocol:@protocol(MCThisPaymentProtocol)]);
        id<MCThisPaymentProtocol, MCTonightsBillTransfer> theDestination = [[segue destinationViewController] viewControllers][0];
        [theDestination setThisPayment:[_tonightsBill getFirstPaymentWithoutAPayer]];
        [theDestination setTonightsBill:_tonightsBill];
    } else {
        if ([[[segue destinationViewController] viewControllers][0] respondsToSelector:@selector(setTonightsBill:)]) {
            [[[segue destinationViewController] viewControllers][0] setTonightsBill:_tonightsBill];
        }
        if ([[[segue destinationViewController] viewControllers][0] respondsToSelector:@selector(setSendMailObject:)]) {
            [[[segue destinationViewController] viewControllers][0] setSendMailObject:[self mailDelegate]];
        }
        
        if ([[[segue destinationViewController] viewControllers][0] respondsToSelector:@selector(setThisPayment:)]) {
            MCPayment *thePayment;
            NSIndexPath *indexPathOfSelectedRow = [[self tableView] indexPathForSelectedRow];
            if (indexPathOfSelectedRow) {
                thePayment = [_dataController objectAtIndexPath:indexPathOfSelectedRow];
            }
            if ([[[segue destinationViewController] viewControllers][0] respondsToSelector:@selector(setIsNew:)]) {
                if (thePayment) {
                    [[[segue destinationViewController] viewControllers][0] setIsNew:YES];
                } else {
                    [[[segue destinationViewController] viewControllers][0] setIsNew:NO];
                }
            }
            [[[segue destinationViewController] viewControllers][0] setThisPayment:thePayment];
        }
    }

    
}

@end
