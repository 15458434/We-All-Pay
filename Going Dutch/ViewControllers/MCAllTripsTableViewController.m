//
//  MCSharedBillsViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCAllTripsTableViewController.h"
#import "MCSharedBillTableViewController.h"
#import "MCPaymentViewController.h"
#import "MCEditTripViewController.h"

#import "MCTwoLabelsTitleView.h"

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"
#import "MCCurrency+addons.h"

#import "MCTonightsBillTransfer.h"

#import "UIViewController+WeAllPayStore.h"

#import "MCWhoPayingUserDefaultsStoreInterface+WeAllPay.h"

#import "We_all_pay-Swift.h"

typedef NS_ENUM(BOOL, MCTonightsBillStatus) {
    isClosed,
    isOpened
};

@interface MCAllTripsTableViewController ()

@property (nonatomic, strong) NSFetchedResultsController *dataController;
@property (nonatomic) MCTonightsBillStatus isATonightsBillOpened;

@property (nonatomic) BOOL isEmptyMessageShownInstantForFirstBoot;

@end

@implementation MCAllTripsTableViewController

#pragma mark - Actions

- (void) addButtonFromTableViewCell:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    
	NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint: [touch locationInView:[self tableView]]];
	if (indexPath != nil)
	{
        [self tableView:[self tableView] accessoryButtonTappedForRowWithIndexPath:indexPath];
	}
}

- (IBAction)tellAFriendAboutWeAllPay:(id)sender
{
    NSArray *dataToShare = @[[NSString stringWithString:NSLocalizedString(@"I_FOUND_WE_ALL_PAY", @"Hi, I found this easy to use iPhone app to share a bill amongst friends. It is called We All Pay.")]];
    UIActivityViewController *shareMe = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
    [self presentViewController:shareMe animated:YES completion:nil];
}

#pragma mark - New in this class.

- (void)setEmptyMessage
{
    if (![[_dataController fetchedObjects] count] == 0) {
        [UIView animateWithDuration:1.0 animations:^{
            [[emptyMessage bigMessage] setAlpha:0.0];
            [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        } completion:nil];
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
    if (![[_dataController fetchedObjects] count] == 0) {
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
    BOOL success = [_dataController performFetch:&error];
    if (!success) {
        NSLog(@"%@: performFetch went wrong: %@", self, error);
    }
}

#pragma mark - Inherited from super

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _isATonightsBillOpened = isClosed;
    _isEmptyMessageShownInstantForFirstBoot = false;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    emptyMessage = [[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage" owner:self options:nil][0];
    [[emptyMessage bigMessage] setAlpha:0.0];
    [[self tableView] setBackgroundView:emptyMessage];
    
    [self startRespondingToStoreChangeNotifications];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_isATonightsBillOpened == isOpened) {
        _isATonightsBillOpened = isClosed;
    }
    
    if (!_dataController) {
        _dataController = [[MCWeAllPayStoreController defaultStore] allTripsDataControllerForDelegate:self];
        [self performFetch];
    }
    
    if (_isEmptyMessageShownInstantForFirstBoot == false) {
        [self setEmptyMessageNow];
        _isEmptyMessageShownInstantForFirstBoot = true;
    } else {
        [self setEmptyMessage];
    }
    
    [[self tableView] reloadData];
    [[self navigationController] setToolbarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _dataController = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [MCTools setAdBannerIfNotPaid:NO forViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self stopRespondingToStorechangeNotifications];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
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

#pragma mark - MCReturnPaymentViewControllerDelegate

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (self.isViewLoaded && self.view.window && _isATonightsBillOpened == isClosed) {
        [[self tableView] beginUpdates];
    }

}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.isViewLoaded && self.view.window && _isATonightsBillOpened == isClosed) {
#if DEBUG
        NSLog(@"executing tableView endUpdates");
#endif
        [[self tableView] endUpdates];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (self.isViewLoaded && self.view.window && _isATonightsBillOpened == isClosed) {
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
    MCSharedBill *thisTrip = [_dataController objectAtIndexPath:indexPath];
    MCAllTripsTableViewCell *allTripsTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"MCAllTripsTableViewCell"];
    
    if (![thisTrip tripName]) {
        [[allTripsTableViewCell tripLabel] setText:@"..."];
    } else {
        [[allTripsTableViewCell tripLabel] setText:[thisTrip tripName]];
    }
    [[allTripsTableViewCell peoplePresentLabel] setText:[thisTrip stringOfApproxPeoplePresent]];

    if ([thisTrip areAllExchangeRatesValid]) {
        
        NSNumberFormatter *nf = [[thisTrip mainCurrency] numberFormatter];
        [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
        NSString *moneyString = [nf stringFromNumber:[thisTrip totalSumOfMoneyOfThisSharedBill]];
        [[allTripsTableViewCell totalCostLabel] setHidden:NO];
        [[allTripsTableViewCell waitingForXRatesIndicator] stopAnimating];
        [[allTripsTableViewCell totalCostLabel] setText:moneyString];
    } else {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
        NSString *moneyString = [nf stringFromNumber:[thisTrip totalSumOfMoneyOfThisSharedBill]];
        [[allTripsTableViewCell totalCostLabel] setText:moneyString];
        [[allTripsTableViewCell totalCostLabel] setHidden:YES];
        [[allTripsTableViewCell waitingForXRatesIndicator] startAnimating];
    }

    // fill extraLabel with dateModified.
    if (!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterMediumStyle];
        [df setTimeStyle:NSDateFormatterShortStyle];
    }
    [[allTripsTableViewCell extraLabel] setText:[df stringFromDate:[thisTrip dateModified]]];
    
    return allTripsTableViewCell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MCSharedBill *toBeDeleteSharedBill = [_dataController objectAtIndexPath:indexPath];

        [MCWhoPayingUserDefaultsStoreInterface sendInvalidUserDefaultsIfTonightsBillIs:toBeDeleteSharedBill];
        [MCSharedBill deleteSharedbill:toBeDeleteSharedBill];
        [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
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
    return 64;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    MCSharedBill *thisBill = [_dataController objectAtIndexPath:indexPath];
    MCPaymentViewController *pvc = [[MCPaymentViewController alloc] initWithExistingPayment:nil fromBill:thisBill];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:pvc];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    }
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - UIStoryboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
#if DEBUG
    NSLog(@"prepareForSegue: %@", [segue identifier]);
#endif
    if ([[segue identifier] isEqualToString:@"newTonightsBill"]) {
        _isATonightsBillOpened = isOpened;
    }
    if ([[segue identifier] isEqualToString:@"openTonightsBill"]) {
        _isATonightsBillOpened = isOpened;
    }
    MCSharedBill *theBill;
    if ([sender isKindOfClass:[NSArray class]]) {
        if ([[segue destinationViewController] conformsToProtocol:@protocol(MCTonightsBillTransfer)]) {
            [[segue destinationViewController] setTonightsBill:[sender firstObject]];
        }
    } else {
        NSIndexPath *indexPathOfSelectedRow = [[self tableView] indexPathForSelectedRow];
        if (indexPathOfSelectedRow) {
            theBill = [_dataController objectAtIndexPath:indexPathOfSelectedRow];
        }
        if ([[segue destinationViewController] conformsToProtocol:@protocol(MCTonightsBillTransfer)]) {
            [[segue destinationViewController] setTonightsBill:theBill];
        }
    }
    
    if ([[segue identifier] isEqualToString:@"newPaymentFromEvents"]) {
        MCSharedBill *theBill = [sender firstObject];
        if ([[segue destinationViewController] conformsToProtocol:@protocol(MCTonightsBillTransfer)]) {
            [[segue destinationViewController] setTonightsBill:theBill];
        }
        if ([[segue destinationViewController] conformsToProtocol:@protocol(MCPathComponentsToOpenProtocol) ]) {
            [[segue destinationViewController] setPathComponentsToOpen:sender];
        }
    }
}

@end
