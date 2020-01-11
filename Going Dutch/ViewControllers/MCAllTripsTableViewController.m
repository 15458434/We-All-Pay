//
//  MCSharedBillsViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import FirebaseAnalytics;

#import "MCAllTripsTableViewController.h"
#import "MCSharedBillTableViewController.h"
#import "MCPaymentViewController.h"
#import "MCEditTripViewController.h"

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"
#import "MCCurrency+addons.h"

#import "MCTonightsBillTransfer.h"

#import "UIViewController+WeAllPayStore.h"

#import "We_all_pay-Swift.h"

typedef NS_ENUM(BOOL, MCTonightsBillStatus) {
    MCTonightsBillStatusClosed,
    MCTonightsBillStatusOpened
};

@interface MCAllTripsTableViewController ()

@property (nonatomic, strong) IBOutlet MCEventsModel *model;

@property (nonatomic) MCTonightsBillStatus isATonightsBillOpened;

@property (nonatomic) BOOL isEmptyMessageShownInstantForFirstBoot;

@property (nonatomic, strong) NSIndexPath *selectedIndexPathForAction;

@property (nonatomic, strong) SideMenuTransitioner *iScreenTransitioner;

@end

@implementation MCAllTripsTableViewController

#pragma mark - Actions

- (IBAction)newEventPressed:(id)sender {
    [FIRAnalytics logEventWithName:@"New Event" parameters:nil];
}

- (IBAction)iButtonPressed:(id)sender {
    [FIRAnalytics logEventWithName:@"Open Info Screen" parameters:nil];
}

#pragma mark - New in this class.

- (void)setEmptyMessage {
    if ([[_model.fetchEventsController fetchedObjects] count] != 0) {
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

- (void)setEmptyMessageNow {
    if ([[_model.fetchEventsController fetchedObjects] count] != 0) {
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

- (void)prepareUserActivity {
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
    MCSharedBill *poorSucker = [_model.fetchEventsController objectAtIndexPath:indexPath];
    [WhoPayingUserDefaultsStoreInterface sendInvalidUserDefaultsIfTonightsBillIs:poorSucker];
    [_model deleteWithEvent:poorSucker];
    [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
}

#pragma mark - UIViewController+WeAllPayStore notifications

- (void)storeWillBeSwapped:(NSNotification *)notification {
    [super storeWillBeSwapped:notification];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[self view] setUserInteractionEnabled:NO];
    });
}

- (void)storeDidSwap:(NSNotification *)notification {
    [super storeDidSwap:notification];
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (self.model.fetchEventsController) {
            NSError *fetchError;
            if (![self.model.fetchEventsController performFetch:&fetchError]) {
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - UITableViewController

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _model.fetchEventsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _model.fetchEventsController.sections[section].numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCSharedBill *thisTrip = [_model.fetchEventsController objectAtIndexPath:indexPath];
    MCAllTripsTableViewCell *allTripsTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"MCAllTripsTableViewCell"];
    
    if (![thisTrip tripName]) {
        [[allTripsTableViewCell tripLabel] setText:NSLocalizedString(@"...", @"String that shows empty string")];
    } else {
        [[allTripsTableViewCell tripLabel] setText:[thisTrip tripName]];
    }
    [[allTripsTableViewCell peoplePresentLabel] setText:[thisTrip stringOfApproxPeoplePresent]];

    if ([thisTrip areAllExchangeRatesValid]) {
        CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:thisTrip.mainCurrency.code];
        NSString *moneyString = [cf stringForObjectValue:[thisTrip totalSumOfMoneyOfThisSharedBill]];
        [[allTripsTableViewCell totalCostLabel] setHidden:NO];
        [[allTripsTableViewCell waitingForXRatesIndicator] stopAnimating];
        [[allTripsTableViewCell totalCostLabel] setText:moneyString];
    } else {
        CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:thisTrip.mainCurrency.code];
        NSString *moneyString = [cf stringForObjectValue:[thisTrip totalSumOfMoneyOfThisSharedBill]];
        [[allTripsTableViewCell totalCostLabel] setText:moneyString];
        [[allTripsTableViewCell totalCostLabel] setHidden:YES];
        [[allTripsTableViewCell waitingForXRatesIndicator] startAnimating];
    }

    // fill extraLabel with dateModified.
    if (!_df) {
        _df = [[NSDateFormatter alloc] init];
        [_df setDateStyle:NSDateFormatterMediumStyle];
        [_df setTimeStyle:NSDateFormatterShortStyle];
    }
    [[allTripsTableViewCell extraLabel] setText:[_df stringFromDate:[thisTrip dateModified]]];
    
    return allTripsTableViewCell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteBillAtIndexpath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MCSharedBill *selectedEvent = [_model.fetchEventsController objectAtIndexPath:indexPath];
    if (selectedEvent.tripName) {
        [FIRAnalytics logEventWithName:@"Open event" parameters:@{@"Event name": selectedEvent.tripName, @"Event identifier": selectedEvent.uniqueBillId}];
    } else {
        [FIRAnalytics logEventWithName:@"Open event" parameters:@{@"Event identifier": selectedEvent.uniqueBillId}];
    }
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
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

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    _emptyMessage = [[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage" owner:self options:nil][0];
    [[_emptyMessage bigMessage] setAlpha:0.0];
    [[self tableView] setBackgroundView:_emptyMessage];
    
    [self startRespondingToStoreChangeNotifications];
    
    [self prepareUserActivity];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_isATonightsBillOpened == MCTonightsBillStatusOpened) {
        _isATonightsBillOpened = MCTonightsBillStatusClosed;
    }
    
    if (!_model.fetchEventsController) {
        NSManagedObjectContext *managedObjectContext = MCWeAllPayStoreController.defaultStore.mainThreadContext;
        [_model prepareForUseWithManagedObjectContext:managedObjectContext forDelegate:self];
        [[self tableView] reloadData];
    }
    
    if (_isEmptyMessageShownInstantForFirstBoot == false) {
        [self setEmptyMessageNow];
        _isEmptyMessageShownInstantForFirstBoot = true;
    } else {
        [self setEmptyMessage];
    }
    
    [[self navigationController] setToolbarHidden:YES animated:YES];
    
    if (self.userActivity) {
        [self.userActivity becomeCurrent];
    }
    
    [MCAdEngine presentPrivacyConsentRequestIfNecessaryFromViewController:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
#ifdef DEBUG
    NSLog(@"prepareForSegue: %@", [segue identifier]);
#endif
    if ([[segue identifier] isEqualToString:@"newTonightsBill"]) {
        _isATonightsBillOpened = MCTonightsBillStatusOpened;
    }
    if ([[segue identifier] isEqualToString:@"openTonightsBill"]) {
        _isATonightsBillOpened = MCTonightsBillStatusOpened;
    }
    MCSharedBill *theBill;
    if ([sender isKindOfClass:[NSArray class]]) {
        if ([[segue destinationViewController] conformsToProtocol:@protocol(MCTonightsBillTransfer)]) {
            [[segue destinationViewController] setTonightsBill:[sender firstObject]];
        }
    } else {
        NSIndexPath *indexPathOfSelectedRow = [[self tableView] indexPathForSelectedRow];
        if (indexPathOfSelectedRow) {
            theBill = [_model.fetchEventsController objectAtIndexPath:indexPathOfSelectedRow];
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
    if ([[segue identifier] isEqualToString:@"selectMainCurrency"]) {
        MCSharedBill *theBill = _model.fetchEventsController.fetchedObjects[_selectedIndexPathForAction.row];
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        SelectCurrencyTableViewController *currencySelector = (SelectCurrencyTableViewController *)navController.viewControllers.firstObject;
        currencySelector.currencyUpdateModel = [[EventUpdateCurrencyModel alloc] initWith:theBill];
    } else if ([segue.identifier isEqualToString:@"iScreenSegue"]) {
        UIViewController *navigationController = segue.destinationViewController;
        navigationController.modalPresentationStyle = UIModalPresentationCustom;
        _iScreenTransitioner = [[SideMenuTransitioner alloc] init];
        navigationController.transitioningDelegate = _iScreenTransitioner;
    }
}

#pragma mark - UIResponder

#pragma mark - NSObject

- (void)dealloc {
    [self stopRespondingToStorechangeNotifications];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _isATonightsBillOpened = MCTonightsBillStatusClosed;
    _isEmptyMessageShownInstantForFirstBoot = NO;
}

@end
