//
//  MCAllTripsTableViewController-iPad.m
//  We all pay
//
//  Created by Mark Cornelisse on 31-03-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import FirebaseAnalytics;

#import "MCAllTripsTableViewController-iPad.h"
#import "UIViewController+WeAllPayStore.h"

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCCurrency+addons.h"

#import "MCTonightsBillTransfer.h"

#import "We_all_pay-Swift.h"

@interface MCAllTripsTableViewController_iPad ()

@property (nonatomic, strong) NSFetchedResultsController *dataController;

@property (nonatomic) BOOL isEmptyMessageShownInstantForFirstBoot;

@property (nonatomic, strong) NSIndexPath *selectedIndexPathForAction;

@end

@implementation MCAllTripsTableViewController_iPad

#pragma mark - IBActions

- (IBAction)newEventPressed:(id)sender
{
    [FIRAnalytics logEventWithName:@"New Event" parameters:nil];
}


#pragma mark - New in this class

- (void)performFetch
{
    NSError *error;
    BOOL success = [_dataController performFetch:&error];
    if (!success) {
        NSLog(@"Something went wrong: %@", error);
    }
}

- (void)setEmptyMessage
{
    if ([[_dataController fetchedObjects] count] != 0) {
        [UIView animateWithDuration:1.0 animations:^{
            [[self.emptyMessage bigMessage] setAlpha:0.0];
            [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        } completion:nil];
    } else {
        if ([[_emptyMessage bigMessage] alpha] < 1.0) {
            [UIView animateWithDuration:1.0 animations:^{
                [[self.emptyMessage bigMessage] setAlpha:1.0];
                [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            } completion:nil];
        }
    }
}

- (void)setEmptyMessageNow
{
    if ([[_dataController fetchedObjects] count] != 0) {
        [UIView animateWithDuration:0.0 animations:^{
            [[self.emptyMessage bigMessage] setAlpha:0.0];
            [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        } completion:nil];
    } else {
        if ([[_emptyMessage bigMessage] alpha] < 1.0) {
            [UIView animateWithDuration:0.0 animations:^{
                [[self.emptyMessage bigMessage] setAlpha:1.0];
                [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            } completion:nil];
        }
    }
}

- (void)prepareUserActivity
{
    if (@available(iOS 9.0, *)) {
        NSUserActivity *activity = [[NSUserActivity alloc] initWithActivityType:@"com.GreenHair.We-all-pay.SharingExpenses"];
        activity.title = NSLocalizedString(@"We all pay - Sharing Expenses and bill splitting made easy", @"The title of the app");
        NSString *keywordsFilePath = [[NSBundle mainBundle] pathForResource:@"We all pay keywords" ofType:@"plist"];
        activity.keywords = [NSSet setWithArray:[NSArray arrayWithContentsOfFile:keywordsFilePath]];
        activity.eligibleForHandoff = NO;
        activity.eligibleForSearch = YES;
        activity.eligibleForPublicIndexing = YES;
        activity.requiredUserInfoKeys = [[NSSet alloc] init];
        self.userActivity = activity;
    }
}

- (void)deleteBillAtIndexpath:(NSIndexPath *)indexPath {
    MCSharedBill *toBeDeleteSharedBill = [_dataController objectAtIndexPath:indexPath];
    
    [WhoPayingUserDefaultsStoreInterface sendInvalidUserDefaultsIfTonightsBillIs:toBeDeleteSharedBill];
    [MCSharedBill deleteSharedbill:toBeDeleteSharedBill];
    [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
}

#pragma mark - Inherited from super

- (void)awakeFromNib
{
    [super awakeFromNib];
    _isEmptyMessageShownInstantForFirstBoot = false;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self startRespondingToStoreChangeNotifications];
    
    _emptyMessage = [[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage_iPad" owner:self options:nil][0];
    [[_emptyMessage bigMessage] setAlpha:0.0];
    [[self tableView] setBackgroundView:_emptyMessage];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self prepareUserActivity];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_dataController) {
        _dataController = [[MCWeAllPayStoreController defaultStore] allTripsDataControllerForDelegate:self];
        [self performFetch];
        [[self tableView] reloadData];
        if (_isEmptyMessageShownInstantForFirstBoot == false) {
            [self setEmptyMessageNow];
            _isEmptyMessageShownInstantForFirstBoot = true;
        } else {
            [self setEmptyMessage];
        }
    }
    
    if (self.userActivity) {
        [self.userActivity becomeCurrent];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _dataController = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    // When view is not loaded it's not onscreen. Therefor the dataController can be nil;
    if (![self isViewLoaded]) {
        _dataController = nil;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Core Data Notifications

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
        if (self.dataController) {
            NSError *fetchError;
            if (![self.dataController performFetch:&fetchError]) {
                NSLog(@"Error fetching: %@", fetchError);
            }
        }
        [[self tableView] reloadData];
        [self setEmptyMessage];
        [[self view] setUserInteractionEnabled:YES];
    });
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
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self setEmptyMessage];
            break;
            
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self setEmptyMessage];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [[self tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

#pragma mark - UITableView Delegate

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [FIRAnalytics logEventWithName:@"Open Event" parameters:nil];
//    [self performSegueWithIdentifier:@"openEvent" sender:self];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Delete action
    NSString *deleteTitle = NSLocalizedString(@"Delete", @"Text on a delete button");
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:deleteTitle handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
#ifdef DEBUG
        NSLog(@"Delete action pressed");
#endif
        [self deleteBillAtIndexpath:indexPath];
    }];
    // Change MainCurrency action
    NSString *selectMainCurrencyTitle = NSLocalizedString(@"€$£¥", @"Text on a button to select a different currency");
    UITableViewRowAction *selectCurrencyAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:selectMainCurrencyTitle handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
#ifdef DEBUG
        NSLog(@"Change currency pressed");
#endif
        // Open currency picker in mainCurrency mode
        [self performSegueWithIdentifier:@"selectMainCurrency" sender:self];
        self.selectedIndexPathForAction = indexPath;
    }];
    return @[deleteAction, selectCurrencyAction];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[_dataController fetchedObjects] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCSharedBill *thisTrip = [_dataController objectAtIndexPath:indexPath];
    AllTripsTableViewCell_iPad *allTripsTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"MCAllTripsTableViewCell_iPad"];
    
    if (![thisTrip tripName]) {
        [[allTripsTableViewCell tripLabel] setText:NSLocalizedString(@"...", @"String that shows empty string")];
    } else {
        [[allTripsTableViewCell tripLabel] setText:[thisTrip tripName]];
    }
    [[allTripsTableViewCell peoplePresentLabel] setText:[thisTrip stringOfApproxPeoplePresentWithFullNames]];
    
    if ([thisTrip areAllExchangeRatesValid]) {
        [[allTripsTableViewCell activityIndicator] stopAnimating];
        [[allTripsTableViewCell totalCostLabel] setHidden:NO];
        
        CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:thisTrip.mainCurrency.code];
        allTripsTableViewCell.totalCostLabel.text = [cf stringFor:thisTrip.totalSumOfMoneyOfThisSharedBill];
    } else {
        [[allTripsTableViewCell activityIndicator] startAnimating];
        [[allTripsTableViewCell totalCostLabel] setHidden:YES];
    }
    
    // fill extraLabel with dateModified.
    if (!_df) {
        _df = [[NSDateFormatter alloc] init];
        [_df setDateStyle:NSDateFormatterFullStyle];
        // [df setTimeStyle:NSDateFormatterShortStyle];
    }
    [[allTripsTableViewCell extraLabel] setText:[_df stringFromDate:[thisTrip dateModified]]];
    
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
        [FIRAnalytics logEventWithName:@"Delete event" parameters:nil];
        // Delete the row from the data source
        [self deleteBillAtIndexpath:indexPath];
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
    
    if ([[segue identifier] isEqualToString:@"selectMainCurrency"]) {
        MCSharedBill *theBill = _dataController.fetchedObjects[_selectedIndexPathForAction.row];
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        SelectCurrencyTableViewController *currencySelector = (SelectCurrencyTableViewController *)navController.viewControllers.firstObject;
        currencySelector.currencyUpdateModel = [[EventUpdateCurrencyModel alloc] initWith:theBill];
        return;
    }
    
    MCSharedBill *theBill;
    NSIndexPath *indexPathOfSelectedRow = [[self tableView] indexPathForSelectedRow];
    if (indexPathOfSelectedRow) {
        theBill = [_dataController objectAtIndexPath:indexPathOfSelectedRow];
    }
    if ([[segue destinationViewController] conformsToProtocol:@protocol(MCTonightsBillTransfer)]) {
        if (theBill) {
            [[segue destinationViewController] setTonightsBill:theBill];
        } else {
            [[segue destinationViewController] setTonightsBill:[MCSharedBill addSharedBill]];
            [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
        }
    }
}

@end
