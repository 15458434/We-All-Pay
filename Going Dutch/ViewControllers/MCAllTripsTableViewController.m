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

#import "MCAllTripsTableViewCell.h"
#import "MCTwoLabelsTitleView.h"
#import "MCTableEmptyMessage.h"

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"

#import "MCTonightsBillTransfer.h"

#import "UIViewController+WeAllPayStore.h"

@interface MCAllTripsTableViewController ()

@property (nonatomic, strong) NSFetchedResultsController *dataController;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    // [[self navigationItem] setTitle:NSLocalizedString(@"BACK_TITLE_ALL_TRIPS_VIEW", @"back")];
    
    // Load the nib file
    UINib *nib = [UINib nibWithNibName:@"MCAllTripsTableViewCell" bundle:nil];
    
    // Register this nib that contains the cell.
    [[ self tableView] registerNib:nib forCellReuseIdentifier:@"MCAllTripsTableViewCell"];
    
    emptyMessage = [[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage" owner:self options:nil][0];
    [[emptyMessage bigMessage] setAlpha:0.0];
    [[self tableView] setBackgroundView:emptyMessage];
    
    [self startRespondingToStoreChangeNotifications];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[MCTools setAdBannerIfNotPaid:YES forViewController:self];
    
    /*
    // Set the titleView.
    if (!titleView) {
        titleView = [[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil][0];
        [[self navigationItem] setTitleView:titleView];
    }
    [[titleView mainLabel] setText:@"We All Pay"];
    [[titleView subLabel] setText:[NSString stringWithFormat:@"%@ build %@", [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]]];
    [[titleView mainLabel] setTextColor:[UIColor whiteColor]];
    [[titleView subLabel] setTextColor:[UIColor whiteColor]];
     */
    
    if (!_dataController) {
        _dataController = [[MCWeAllPayStoreController defaultStore] allTripsDataControllerForDelegate:self];
        [self performFetch];
    }
    
    if ([[MCWeAllPayStoreController defaultStore] isDocumentStateNormal]) {
        [self setEmptyMessage];
    }
    
    [[self tableView] reloadData];
    [[self navigationController] setToolbarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"MCAllTripsTableView_iPhone"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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

/*- (void)removePayment:(MCPayment *)payment fromPaymentViewController:(MCPaymentViewController *)pvc
{
    NSLog(@"removePayment in AllTripsTableViewController.");
    [[pvc tonightsBill] removePayment:payment];
    [[self tableView] reloadData];
}*/

#pragma mark - NSFetchedResultsControllerDelegate

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
    MCSharedBill *thisTrip = [_dataController objectAtIndexPath:indexPath];
    MCAllTripsTableViewCell *allTripsTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"MCAllTripsTableViewCell"];
    
    if (![thisTrip tripName]) {
        [[allTripsTableViewCell tripLabel] setText:@"..."];
    } else {
        [[allTripsTableViewCell tripLabel] setText:[thisTrip tripName]];
    }
    [[allTripsTableViewCell peoplePresentLabel] setText:[thisTrip stringOfApproxPeoplePresent]];

    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *moneyString = [nf stringFromNumber:[thisTrip totalSumOfMoneyOfThisSharedBill]];
    [[allTripsTableViewCell totalCostLabel] setText:moneyString];
    
    
    // fill extraLabel with dateModified.
    if (!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterMediumStyle];
        [df setTimeStyle:NSDateFormatterShortStyle];
    }
    [[allTripsTableViewCell extraLabel] setText:[df stringFromDate:[thisTrip dateModified]]];
    
    /*
    CGRect buttonRect = CGRectMake(0, 0, 44, 44);
    UIButton *accessoryButton = [[UIButton alloc] initWithFrame:buttonRect];
    UIImage *plusSign = [UIImage imageNamed:@"plus sign"];
    [accessoryButton setImage:plusSign forState:UIControlStateNormal];
    [accessoryButton addTarget:self action:@selector(addButtonFromTableViewCell:event:) forControlEvents:UIControlEventTouchUpInside];
    [allTripsTableViewCell setAccessoryView:accessoryButton];
     */
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"openTonightsBill" sender:self];
}

#pragma mark - UIStoryboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MCSharedBill *theBill;
    NSIndexPath *indexPathOfSelectedRow = [[self tableView] indexPathForSelectedRow];
    if (indexPathOfSelectedRow) {
        theBill = [_dataController objectAtIndexPath:indexPathOfSelectedRow];
    }
    if ([[segue destinationViewController] conformsToProtocol:@protocol(MCTonightsBillTransfer)]) {
        [[segue destinationViewController] setTonightsBill:theBill];
    }
}

@end
