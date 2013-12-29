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

@interface MCAllTripsTableViewController ()

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
    NSArray *dataToShare = [NSArray arrayWithObject:[NSString stringWithFormat:@"Hi, I found this easy to use iPhone app to share a bill amongst friends. It's called \"We All Pay\"."]];
    UIActivityViewController *shareMe = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
    [self presentViewController:shareMe animated:YES completion:nil];
}

#pragma mark - New in this class.

- (void)setDataController
{
    NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument]managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCSharedBill"];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO]]];
    
    dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                         managedObjectContext:context
                                                           sectionNameKeyPath:nil
                                                                    cacheName:nil];
    [dataController setDelegate:self];
    UIManagedDocument *weAllPayDocument = [[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performFetchAndReloadTableView:) name:UIDocumentStateChangedNotification object:weAllPayDocument];
}

- (void)setEmptyMessage
{
    if (![[dataController fetchedObjects] count] == 0) {
        [UIView animateWithDuration:1.0 animations:^{
            [[emptyMessage bigMessage] setAlpha:0.0];
            [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        } completion:nil];
    } else {
        [UIView animateWithDuration:1.0 animations:^{
            [[emptyMessage bigMessage] setAlpha:1.0];
            [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        } completion:nil];
    }
}

- (void)performFetchAndReloadTableView:(NSNotification *)notification
{
    UIManagedDocument *weAllPayDocument = [[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument];
    if ([weAllPayDocument documentState] == UIDocumentStateNormal) {
        [self performFetch];
        [[self tableView] reloadData];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self setEmptyMessage];
    }
}

- (void)performFetch
{
    NSError *error;
    BOOL success = [dataController performFetch:&error];
    if (!success) {
        NSLog(@"Something went wrong");
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    // Set the titleView.
    if (!titleView) {
        titleView = [[[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil] objectAtIndex:0];
        [[self navigationItem] setTitleView:titleView];
    }
    [[titleView mainLabel] setText:@"We All Pay"];
    [[titleView subLabel] setText:[NSString stringWithFormat:@"%@ build %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [[titleView mainLabel] setTextColor:[UIColor whiteColor]];
        [[titleView subLabel] setTextColor:[UIColor whiteColor]];
    }
    
    [[self tableView] reloadData];
    [[self navigationController] setToolbarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [MCTools setAdBannerIfNotPaid:YES forViewController:self];
    
    [[self navigationItem] setTitle:@"back"];
    
    if (!dataController) {
        [self setDataController];
    }
    
    // Load the nib file
    UINib *nib = [UINib nibWithNibName:@"MCAllTripsTableViewCell" bundle:nil];
    
    // Register this nib that contains the cell.
    [[ self tableView] registerNib:nib forCellReuseIdentifier:@"MCAllTripsTableViewCell"];
    
    emptyMessage = [[[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage" owner:self options:nil] objectAtIndex:0];
    [[emptyMessage bigMessage] setAlpha:0.0];
    [[self tableView] setBackgroundView:emptyMessage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            [self setEmptyMessage];
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
    MCSharedBill *thisTrip = [dataController objectAtIndexPath:indexPath];
    MCAllTripsTableViewCell *allTripsTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"MCAllTripsTableViewCell"];
    
    [[allTripsTableViewCell tripLabel] setText:[thisTrip tripName]];
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
        MCSharedBill *toBeDeleteSharedBill = [dataController objectAtIndexPath:indexPath];
        [NSFetchedResultsController deleteCacheWithName:[NSString stringWithFormat:@"All persons cache of trip: %@", [toBeDeleteSharedBill uniqueBillId]]];
        [NSFetchedResultsController deleteCacheWithName:[NSString stringWithFormat:@"All payments cache of trip: %@", [toBeDeleteSharedBill uniqueBillId]]];
        [MCSharedBill deleteSharedbill:toBeDeleteSharedBill];
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
    return 60;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    MCSharedBill *thisBill = [dataController objectAtIndexPath:indexPath];
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
        theBill = [dataController objectAtIndexPath:indexPathOfSelectedRow];
    }
    if ([[segue destinationViewController] respondsToSelector:@selector(setTonightsBill:)]) {
        [[segue destinationViewController] setTonightsBill:theBill];
    }
}

@end
