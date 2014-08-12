//
//  MCAllTripsTableViewController-iPad.m
//  We all pay
//
//  Created by Mark Cornelisse on 31-03-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCAllTripsTableViewController-iPad.h"

#import "MCAllTripsTableViewCell_iPad.h"
#import "MCTableEmptyMessage_iPad.h"

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"

#import "MCTonightsBillTransfer.h"

@interface MCAllTripsTableViewController_iPad ()

@end

@implementation MCAllTripsTableViewController_iPad

#pragma mark - New in this class

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
    BOOL success = [dataController performFetch:&error];
    if (!success) {
        NSLog(@"Something went wrong");
    }
}

- (void)setEmptyMessage
{
    if (![[dataController fetchedObjects] count] == 0) {
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
    if (![[dataController fetchedObjects] count] == 0) {
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    emptyMessage = [[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage_iPad" owner:self options:nil][0];
    [[emptyMessage bigMessage] setAlpha:0.0];
    [[self tableView] setBackgroundView:emptyMessage];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!dataController) {
        dataController = [[MCWeAllPayStoreController defaultStore] allTripsDataControllerForDelegate:self];
    }
    UIManagedDocument *weAllPayDocument = [[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument];
    if (![[MCWeAllPayStoreController defaultStore] isDocumentStateNormal]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performFetchAndReloadTableView:) name:UIDocumentStateChangedNotification object:weAllPayDocument];
    } else {
        [self performFetch];
        [[self tableView] reloadData];
        [self setEmptyMessageNow];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"AllTripsViewController_iPad"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    dataController = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    // When view is not loaded it's not onscreen. Therefor the dataController can be nil;
    if (![self isViewLoaded]) {
        dataController = nil;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSFetchedResultsController

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

#pragma mark - UITableView Delegate

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"openEvent" sender:self];
}
 */

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[dataController fetchedObjects] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCSharedBill *thisTrip = [dataController objectAtIndexPath:indexPath];
    MCAllTripsTableViewCell_iPad *allTripsTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"MCAllTripsTableViewCell_iPad"];
    
    if (![thisTrip tripName]) {
        [[allTripsTableViewCell tripLabel] setText:@"..."];
    } else {
        [[allTripsTableViewCell tripLabel] setText:[thisTrip tripName]];
    }
    [[allTripsTableViewCell peoplePresentLabel] setText:[thisTrip stringOfApproxPeoplePresentWithFullNames]];
    
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *moneyString = [nf stringFromNumber:[thisTrip totalSumOfMoneyOfThisSharedBill]];
    [[allTripsTableViewCell totalCostLabel] setText:moneyString];
    
    
    // fill extraLabel with dateModified.
    if (!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterFullStyle];
        // [df setTimeStyle:NSDateFormatterShortStyle];
    }
    [[allTripsTableViewCell extraLabel] setText:[df stringFromDate:[thisTrip dateModified]]];
    
    return allTripsTableViewCell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [MCSharedBill deleteSharedbill:[dataController objectAtIndexPath:indexPath]];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    MCSharedBill *theBill;
    NSIndexPath *indexPathOfSelectedRow = [[self tableView] indexPathForSelectedRow];
    if (indexPathOfSelectedRow) {
        theBill = [dataController objectAtIndexPath:indexPathOfSelectedRow];
    }
    if ([[segue destinationViewController] conformsToProtocol:@protocol(MCTonightsBillTransfer)]) {
        if (theBill) {
            [[segue destinationViewController] setTonightsBill:theBill];
        } else {
            [[segue destinationViewController] setTonightsBill:[MCSharedBill addSharedBill]];
        }
    }
}

@end
