//
//  MCSharedBillsViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 09-01-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import FirebaseAnalytics;

#import "MCAllTripsTableViewController.h"
#import "MCPaymentsTableViewController.h"
#import "MCPaymentViewController.h"
#import "MCEditTripViewController.h"
#import "MCSharedBillMainViewController.h"

#import "MCBadgeButton.h"

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"
#import "MCCurrency+addons.h"

#import "MCTonightsBillTransfer.h"
#import "MCEditorType.h"

#import "UIViewController+WeAllPayStore.h"

typedef NS_ENUM(BOOL, MCTonightsBillStatus) {
    MCTonightsBillStatusClosed,
    MCTonightsBillStatusOpened
};

static void * notificationCountContext = &notificationCountContext;

@interface MCAllTripsTableViewController ()

@property (nonatomic, strong) IBOutlet MCEventsModel *model;
@property (nonatomic, strong) UITableViewDiffableDataSource *diffableDataSource;

@property (nonatomic, weak) IBOutlet MCBadgeButton *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *createEventButton;
@property (nonatomic, strong) MCTableEmptyMessage *emptyMessage;
@property (weak, nonatomic) IBOutlet UITableViewHeaderFooterView *headerView;

@property (nonatomic, strong) NSDateFormatter *df;

@property (nonatomic) MCTonightsBillStatus isATonightsBillOpened;

@property (nonatomic) BOOL isEmptyMessageShownInstantForFirstBoot;

@property (nonatomic, strong) NSIndexPath *selectedIndexPathForAction;

@property (nonatomic, strong) SideMenuTransitioner *iScreenTransitioner;

@property (nonatomic, strong) NSArray<NSManagedObject *> *pathComponents;

@end

@implementation MCAllTripsTableViewController

#pragma mark - Actions

- (IBAction)createEventPressed:(id)sender {
    [self performSegueWithIdentifier:@"newTonightsBill" sender:self];
}

- (IBAction)iButtonPressed:(MCBadgeButton *)sender {
    NSParameterAssert(sender);
    if ([sender isEqual:self.infoButton]) {
        [self performSegueWithIdentifier:@"iScreenSegue" sender:sender];
    }
}

#pragma mark - New in this class.

- (void)setEmptyMessageWithDuration:(NSTimeInterval)duration {
    if (_model.fetchEventsController.fetchedObjects.count != 0) {
        [UIView animateWithDuration:duration animations:^{
            self.emptyMessage.bigMessage.alpha = 0.0;
            self.emptyMessage.borderlineView.alpha = 0.0;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        } completion:nil];
    } else {
        if (_emptyMessage.bigMessage.alpha < 1.0) {
            [UIView animateWithDuration:duration animations:^{
                self.emptyMessage.bigMessage.alpha = 1.0;
                self.emptyMessage.borderlineView.alpha = 1.0;
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            } completion:nil];
        }
    }
}

- (void)prepareUserActivity {
    if (@available(iOS 9.0, *)) {
        NSUserActivity *activity = [[NSUserActivity alloc] initWithActivityType:@"com.GreenHair.We-all-pay.SharingExpenses"];
        activity.title = NSLocalizedStringWithDefaultValue(@"app_name", nil, NSBundle.mainBundle, @"We all pay", @"The name of We all pay");
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

#pragma mark - MCPathComponentsToOpenProtocol

- (void)prepareForUseWithPathComponentsToOpen:(NSArray<NSManagedObject *> *)pathComponentsToOpen {
    _pathComponents = pathComponentsToOpen;
    [self performSegueWithIdentifier:@"openEventWithPathComponents" sender:self];
}

#pragma mark - MCReturnPaymentViewControllerDelegate

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithSnapshot:(NSDiffableDataSourceSnapshot<NSString *,NSManagedObjectID *> *)snapshot {
    [_diffableDataSource applySnapshot:snapshot animatingDifferences:YES];
}

#pragma mark - UITableViewController

#pragma mark - UITableViewDataSource

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    MCSharedBill *event = [_model.fetchEventsController objectAtIndexPath:indexPath];
    MCEventTableViewCell *eventCell = (MCEventTableViewCell *)cell;
    [eventCell prepareForUseWith:event];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"openTonightsBill" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Delete action
    NSString *deleteTitle = NSLocalizedStringWithDefaultValue(@"events_view_button_delete_event", nil, NSBundle.mainBundle, @"Delete", @"Text on a delete button");
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:deleteTitle handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
#ifdef DEBUG
        NSLog(@"Delete action pressed");
#endif
        [self deleteBillAtIndexpath:indexPath];
    }];
    // Change MainCurrency action
    NSString *selectMainCurrencyTitle = NSLocalizedStringWithDefaultValue(@"events_view_button_change_main_currency", nil, NSBundle.mainBundle, @"€$£¥", @"Text on a button to select a different main currency for an event");
    UIContextualAction *selectMainCurrencyAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:selectMainCurrencyTitle handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
#ifdef DEBUG
        NSLog(@"Change currency pressed");
#endif
        // Open currency picker in mainCurrency mode
        [self performSegueWithIdentifier:@"selectMainCurrency" sender:self];
        self.selectedIndexPathForAction = indexPath;
    }];
    
    NSArray *actions = @[deleteAction, selectMainCurrencyAction];
    UISwipeActionsConfiguration *swipeActions = [UISwipeActionsConfiguration configurationWithActions:actions];
    return swipeActions;
}

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];
    
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"events_view_title", nil, NSBundle.mainBundle , @"Events", @"A list of all the events on which payments have been shared on the people present");
    NSString *createEventButtonTitle = NSLocalizedStringWithDefaultValue(@"events_view_button_create_event", nil, NSBundle.mainBundle, @"New Event", @"Button in the events view that creates a new event");
    UIFont *font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    NSDictionary<NSAttributedStringKey,id> *attrs = @{NSFontAttributeName: font};
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:createEventButtonTitle attributes:attrs];
    [_createEventButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    
    _emptyMessage = [NSBundle.mainBundle loadNibNamed:@"MCTableEmptyMessage" owner:self options:nil][0];
    _emptyMessage.bigMessage.text = NSLocalizedStringWithDefaultValue(@"events_view_empty_message", nil, NSBundle.mainBundle, @"Press \"New event\" to add the event on which you'd like to share the expenses with your friends.", @"A message shown to the user when the list of events is empty.");
    _emptyMessage.borderlineView.dyInset = 1;
    self.tableView.backgroundView = _emptyMessage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    [self startRespondingToStoreChangeNotifications];
    
    [self prepareUserActivity];
    
    _diffableDataSource = [[UITableViewDiffableDataSource alloc] initWithTableView:self.tableView cellProvider:^UITableViewCell * _Nullable(UITableView * _Nonnull tableView, NSIndexPath * _Nonnull indexPath, id  _Nonnull itemIdentifier) {
        MCEventTableViewCell *allTripsTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"MCAllTripsTableViewCell" forIndexPath:indexPath];
        MCSharedBill *event = [self.model.fetchEventsController objectAtIndexPath:indexPath];
        [allTripsTableViewCell prepareForUseWith:event];
        return allTripsTableViewCell;
    }];
    self.tableView.dataSource = _diffableDataSource;
    
    [MCAdEngine presentPrivacyConsentRequestIfNecessaryFromViewController:self];
#ifdef ADTEST
    [MCAdEngine presentAdTestSuiteFromPresentingViewController:self];
#endif
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
        [self setEmptyMessageWithDuration:0.0];
    }
    
    _emptyMessage.topConstraint.constant = self.headerView.frame.size.height;
    
    [[self navigationController] setToolbarHidden:YES animated:YES];
    
    if (self.userActivity) {
        [self.userActivity becomeCurrent];
    }
    
    // Start KVO
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
    [self.notificationsStateModel addObserver:self forKeyPath:@"messageCount" options:options context:notificationCountContext];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Stop KVO
    [self.notificationsStateModel removeObserver:self forKeyPath:@"messageCount" context:notificationCountContext];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
#ifdef DEBUG
    NSLog(@"prepareForSegue: %@", segue.identifier);
#endif
    if ([segue.identifier isEqualToString:@"newTonightsBill"]) {
        _isATonightsBillOpened = MCTonightsBillStatusOpened;
    } else if ([segue.identifier isEqualToString:@"openTonightsBill"]) {
        _isATonightsBillOpened = MCTonightsBillStatusOpened;
        NSIndexPath *indexPathOfSelectedRow = self.tableView.indexPathForSelectedRow;
        NSParameterAssert(indexPathOfSelectedRow);
        MCSharedBill *selectedEvent = [_model.fetchEventsController objectAtIndexPath:indexPathOfSelectedRow];
        MCSharedBillMainViewController *destination = (MCSharedBillMainViewController *)segue.destinationViewController;
        [destination updateEventWithObjectID:selectedEvent.objectID];
    } else if ([segue.identifier isEqualToString:@"selectMainCurrency"]) {
        MCSharedBill *theBill = _model.fetchEventsController.fetchedObjects[_selectedIndexPathForAction.row];
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        SelectCurrencyTableViewController *currencySelector = (SelectCurrencyTableViewController *)navController.viewControllers.firstObject;
        currencySelector.currencyUpdateModel = [[EventUpdateCurrencyModel alloc] initWith:theBill];
    } else if ([segue.identifier isEqualToString:@"iScreenSegue"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        navigationController.modalPresentationStyle = UIModalPresentationCustom;
        _iScreenTransitioner = [[SideMenuTransitioner alloc] init];
        navigationController.transitioningDelegate = _iScreenTransitioner;
        InfoScreenTableViewController *infoContainerViewController = navigationController.viewControllers.lastObject;
        infoContainerViewController.preferredContentSize = CGSizeMake(320, 0);
        infoContainerViewController.notificationEnvironmentModel = self.notificationsStateModel;
    } else if ([segue.identifier isEqualToString:@"openEventWithPathComponents"]) {
        _isATonightsBillOpened = MCTonightsBillStatusOpened;
        NSParameterAssert(_pathComponents);
        MCSharedBill *event = (MCSharedBill *)_pathComponents[0];
        NSParameterAssert(event);
        MCSharedBillMainViewController *destination = (MCSharedBillMainViewController *)segue.destinationViewController;
        [destination updateEventWithObjectID:event.objectID];
        _pathComponents = nil;
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == notificationCountContext) {
#ifdef DEBUG
        NSLog(@"change: %@", change);
#endif
        NSNumber *changeKeyNumber = (NSNumber *)change[NSKeyValueChangeKindKey];
        NSKeyValueChange keyValueChange = changeKeyNumber.unsignedIntegerValue;
        switch (keyValueChange) {
            case NSKeyValueChangeSetting:
            {
                id new = change[NSKeyValueChangeNewKey];
                if ([new isKindOfClass:[NSNumber class]]) {
                    NSNumber *newMesaageCount = (NSNumber *)new;
                    self.infoButton.count = newMesaageCount.integerValue;
                } else {
                    self.infoButton.count = 0;
                }
            }
                break;
            default:
                break;
        }
    }
}

@end
