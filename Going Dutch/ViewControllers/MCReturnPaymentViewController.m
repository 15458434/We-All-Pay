//
//  MCReturnPaymentViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 07-02-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import FirebaseAnalytics;
@import GoogleMobileAds;

#import "MCReturnPaymentViewController.h"
#import "MCPaymentsTableViewController.h"
#import "MCSharedBillPageViewController.h"

#import "MCCurrency+addons.h"
#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"
#import "MCWeAllPayStoreController.h"
#import "MCBitwiseStuff.h"

#import "We_all_pay-Swift.h"

typedef NS_OPTIONS(NSUInteger, MCReturnPaymentViewControllerState) {
    MCReturnPaymentViewControllerStateNone = 0,
    MCReturnPaymentViewControllerStateXRatesPresent = 1 << 0,
    MCReturnPaymentViewControllerStateShowAdBanner = 1 << 1
};

static void * sectionsContext = &sectionsContext;

@interface MCReturnPaymentViewController () <MCAdBannerEngineDelegate>

@property (nonatomic) MCReturnPaymentViewControllerState uiState;

@property (weak, nonatomic) IBOutlet UITableViewHeaderFooterView *headerView;
@property (nonatomic, strong) MCTableEmptyMessage *emptyMessage;
@property (weak, nonatomic) IBOutlet MCRoundedButton *sendEmailButton;

// Ad Banner
@property (strong, nonatomic) GADBannerView *worstSalesPitchEverView;
@property (strong, nonatomic) IBOutlet MCAdBannerEngine *adBannerEngine;
@property (nonatomic, readonly) NSString *adBannerUnitId;
@property (nonatomic) NSIndexSet *adBannerSectionIndexSet;

@end

@implementation MCReturnPaymentViewController

@synthesize sendMailObject;

#pragma mark - Actions

- (IBAction)sendAsEmailButtonPressed:(MCRoundedButton *)sender {
    [self shareBill:self];
}

- (IBAction)mainCancelButtonPressed:(id)sender {
    if (_model.solution == nil || _model.solution.count == 0) {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Public in this class

- (void)openMailView:(id)sender
{

}

- (void)updateEvent:(MCSharedBill *)event andSendMailDelegate:(MCSharedBillPageViewController *)sendMailDelegate {
    [_model prepareForUseWith:event];
    self.sendMailObject = sendMailDelegate;
}

#pragma mark - Private in this class

- (void)shareBill:(id)sender {
    if ([self.model.event doesEveryoneHaveAnEmailAddress]) {
        [self openMailView:sender];
    } else {
        NSString *title = NSLocalizedStringWithDefaultValue(@"solution_view_alert_title_missing_email_address", nil, NSBundle.mainBundle, @"Unable to send email to all people.", @"Title of an alert shown to the user in case not everyone on the event has an email address.");
        NSString *message = NSLocalizedStringWithDefaultValue(@"solution_view_alert_message_missing_email_address", nil, NSBundle.mainBundle, @"Not all people have a mail address. Add the missing email addresses or send it anyway.", @"Message of an alert shown to the user in case not everyone on the event has an email address.");
        NSString *cancel = NSLocalizedStringWithDefaultValue(@"solution_view_alert_action_dismiss", nil, NSBundle.mainBundle, @"Cancel", @"Text on button to cancel the alert that says there are people without email addresses.");
        NSString *sendAnyway = NSLocalizedStringWithDefaultValue(@"solution_view_alert_action_send_anyway", nil, NSBundle.mainBundle, @"Send anyway", @"Action button on an alert to send email anyway in case not all email addresses have been entered.");
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            // don't do a thing
        }]];
        __weak typeof(self) weakSelf = self;
        [alertController addAction:[UIAlertAction actionWithTitle:sendAnyway style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            typeof(self) strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf openMailView:strongSelf];
            }
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)setEmptyMessageWithDuration:(NSTimeInterval)duration {
    if (_model.solution.count != 0) {
        if (_emptyMessage.bigMessage.alpha > 0.0) {
            [UIView animateWithDuration:duration animations:^{
                self.emptyMessage.bigMessage.alpha = 0.0;
                self.emptyMessage.borderlineView.alpha = 0.0;
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            } completion:nil];
        }
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

- (void)giveSolutionWithCompletion:(void (^)(BOOL success))completion {
    [_emptyMessage.activityIndicator startAnimating];
    _uiState = disableBits(_uiState, MCReturnPaymentViewControllerStateXRatesPresent);
    
    __weak typeof(self) weakSelf = self;
    [_model.event solveWithHandler:^(NSArray *results, NSError *error) {
        NSParameterAssert([NSThread isMainThread]);
        if (error) {
#ifdef DEBUG
            NSLog(@"Error solving: %@", error);
#endif
            NSString *title = NSLocalizedStringWithDefaultValue(@"solution_view_alert_title_cannot_fetch_exchange_rates", nil, NSBundle.mainBundle, @"Unable to fetch exchange rates", @"Title message of an alert that pops up when fetching exchange rates is impossible");
            NSString *message = NSLocalizedStringWithDefaultValue(@"solution_view_alert_message_cannot_fetch_exchange_rates", nil, NSBundle.mainBundle, @"Fetching exchange rates is not possible at this moment. Check your internet connection and/or hit solve to fetch all missing exchange rates at a later time", @"Message in an alert of the solution view that pops up when fetching exchange rates is impossible. It explains what the user can do to refetch exchange rates.");
            NSString *dismissTitle = NSLocalizedStringWithDefaultValue(@"solution_view_alert_action_dismiss_cannot_fetch_exchange_rates", nil, NSBundle.mainBundle, @"Dismiss", @"Button title of an alert view to tell the user We All Pay is unable to fetch exchange rates to calculation a solution.");
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:dismissTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self.emptyMessage.activityIndicator stopAnimating];
                self.emptyMessage.bigMessage.text = message;
            }];
            [alertController addAction:dismissAction];
            [weakSelf presentViewController:alertController animated:YES completion:nil];
            completion(NO);
            return;
        }
        // Workaround for a bug in iOS 9. Call reloadData before calling beginUpdates
        if (@available(iOS 9.0, *)) {
            BOOL shouldReloadData = YES;
            NSInteger numberOfSections = [self.tableView.dataSource numberOfSectionsInTableView:self.tableView];
            for (NSInteger section = 0; section < numberOfSections; section++) {
                if ([self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:section] > 0) {
                    // found a row in current section, do not need to reload data
                    shouldReloadData = NO;
                    break;
                }
            }
            
            if (shouldReloadData) {
                [self.tableView reloadData];
            }
        }
        
        // Update tableView.
        weakSelf.uiState = enableBits(weakSelf.uiState, MCReturnPaymentViewControllerStateXRatesPresent);
        NSString *sectionTitle = [self.model sectionTitleForSection:MCSolutionModelSectionTitleWhoOwesWho];
        SolutionSectionItemsModel *solutionSection = [[SolutionSectionItemsModel alloc] initWithTitle:sectionTitle items:results];
        [self.model addSection:solutionSection];
        [[[self emptyMessage] activityIndicator] stopAnimating];
        
        [self setEmptyMessageWithDuration:0.0];
        
        completion(YES);
    }];
}

- (NSString *)adBannerUnitId {
    return @"ca-app-pub-5354415674074435/5892377702";
}

- (NSIndexSet *)adBannerSectionIndexSet {
    return [NSIndexSet indexSetWithIndex:1];
}

- (MCWhoPaidHowMuchTableViewCell_iPhone *)whoPaidHowMuchCellForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    MCWhoPaidHowMuchTableViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:@"MCWhoPaidHowMuchTableViewCell_iPhone"];
    
    MCPerson *person = [_model.peoplePresentLocalizedSorted objectAtIndex:[indexPath row]];
    [[cell whoPaidHowMuchLabel] setText:[person getFullName]];
    NSNumber *sumSpentByPerson = @(-[[_model.event amountShouldHavePaidBy:person] doubleValue]);
    CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_model.event.mainCurrency.code];
    cell.moneyLabel.text = [cf stringForObjectValue:sumSpentByPerson];
    return cell;
}

- (UITableViewCell *)totalsCellForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    if (indexPath.row < _model.peoplePresentLocalizedSorted.count) {
        MCWhoPaidHowMuchTableViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:@"MCWhoPaidHowMuchTableViewCell_iPhone"];
        
        MCPerson *person = [_model.peoplePresentLocalizedSorted objectAtIndex:[indexPath row]];
        [[cell whoPaidHowMuchLabel] setText:[person getFullName]];
        
        CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_model.event.mainCurrency.code];
        cell.moneyLabel.text = [cf stringForObjectValue:person.totalSumPaid];
        return cell;
    } else {
        MCSolutionOverViewTableViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:@"MCSolutionOverViewTableViewCell_iPhone"];
        NSString *totalSpentString = NSLocalizedStringWithDefaultValue(@"solution_view_cell_label_total_spent", nil, NSBundle.mainBundle, @"Total spent:", @"In the solution view: a label before the total amount of money spent on the entire event.");
        [[cell totalLabel] setText:totalSpentString];
        
        CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_model.event.mainCurrency.code];
        cell.moneyLabel.text = [cf stringForObjectValue:_model.event.totalSumOfMoneyOfThisSharedBill];
        return cell;
    }
}

- (void)startAdBanner {
    self.worstSalesPitchEverView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    [self.adBannerEngine prepareAdBanner:self.worstSalesPitchEverView withAdUnitId:self.adBannerUnitId andViewController:self];
}

#pragma mark - MCAdBannerEngineDelegate

- (void)adEngine:(MCAdBannerEngine *)adEngine putOnScreenBannerView:(GADBannerView *)bannerView {
    AdSectionItemsModel *section = [[AdSectionItemsModel alloc] init];
    if (![_model containsSection:section]) {
        [_model addSection:section];
    }
}

- (void)adEngine:(MCAdBannerEngine *)adEngine putOffScreenBannerView:(GADBannerView *)bannerView {
    AdSectionItemsModel *section = [[AdSectionItemsModel alloc] init];
    [_model removeSection:section];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    MCTableViewSectionItemsModel *sectionModel = _model.sections[section];
    switch (sectionModel.sortIndex) {
        case MCTableViewSectionItemsModelKindSolution: {
            MCWhoOwesWhoTableViewCell *solutionCell = (MCWhoOwesWhoTableViewCell *)cell;
            [solutionCell prepareForUseWithItem:sectionModel.items[indexPath.row] fromModel:_model];
        }
            break;
        case MCTableViewSectionItemsModelKindTotalUsed: {
            
        }
            break;
        case MCTableViewSectionItemsModelKindTotalSpent: {
            
        }
            break;
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *sectionTitleHeader = (UITableViewHeaderFooterView *)view;
    if (@available(iOS 11.0, *)) {
        view.tintColor = [UIColor colorNamed:@"background"];
        sectionTitleHeader.textLabel.textColor = [UIColor colorNamed:@"emptyMessageText"];
    } else {
        // Fallback on earlier versions
    }
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *sectionTitleHeader = (UITableViewHeaderFooterView *)view;
    view.tintColor = nil;
    sectionTitleHeader.textLabel.textColor = nil;
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    MCTableViewSectionItemsModel *sectionModel = _model.sections[section];
    return sectionModel.title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger result = _model.sections.count;
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    MCTableViewSectionItemsModel *sectionModel = _model.sections[section];
    NSInteger count = sectionModel.items.count;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCTableViewSectionItemsModel *sectionModel = _model.sections[indexPath.section];
    switch (sectionModel.sortIndex) {
        case MCTableViewSectionItemsModelKindSolution: {
            MCWhoOwesWhoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MCWhoOwesWhoTableViewCell_iPhone"];
            return cell;
        }
            break;
        case MCTableViewSectionItemsModelKindAd: {
            MCAdBannerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MCAdBannerTableViewCell" forIndexPath:indexPath];
            [cell updateBannerView:_worstSalesPitchEverView];
            return cell;
        }
            break;
        case MCTableViewSectionItemsModelKindTotalUsed:
            return [self whoPaidHowMuchCellForIndexPath:indexPath inTableView:tableView];;
            break;
        case MCTableViewSectionItemsModelKindTotalSpent:
            return [self totalsCellForIndexPath:indexPath inTableView:tableView];
            break;
        default:
            break;
    }
    
    return nil;
}

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];
    
    _emptyMessage = [[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage" owner:self options:nil][0];
    _emptyMessage.bigMessage.text = NSLocalizedStringWithDefaultValue(@"solution_view_list_empty_message", nil, NSBundle.mainBundle, @"Please add people and payments if you want a solution on who owes who.", @"Please add payments and/or people if you want a solution on who owes who.");
    _emptyMessage.borderlineView.dyInset = 20;
    self.tableView.backgroundView = _emptyMessage;
    
    self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"solution_view_title", nil, NSBundle.mainBundle, @"solution", @"Title of the screen that shows the solution to the user of who owes who, what amount of money.");
    
    NSString *sendEmailButtonTitle = NSLocalizedStringWithDefaultValue(@"solution_view_button_send_email", nil, NSBundle.mainBundle, @"send email", @"Title of a button that allows for sending the email with the solution.");
    [_sendEmailButton setTitle:sendEmailButtonTitle forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    __weak typeof(self) weakSelf = self;
    [self giveSolutionWithCompletion:^(BOOL success) {
        if (success && (self.model.sections.count > 0)) {
            [weakSelf startAdBanner];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _emptyMessage.topConstraint.constant = self.headerView.frame.size.height;
    
    // Create KVO
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionPrior;
    [self.model addObserver:self forKeyPath:@"sections" options:options context:sectionsContext];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Destroy KVO
    [self.model removeObserver:self forKeyPath:@"sections" context:sectionsContext];
}

#pragma mark - UIResponder

#pragma mark - NSObject

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == sectionsContext) {
        NSNumber *kindValue = change[NSKeyValueChangeKindKey];
        NSKeyValueChange kind = kindValue.unsignedIntegerValue;
        NSNumber *notificationIsPrior = (NSNumber *)change[NSKeyValueChangeNotificationIsPriorKey];
        if (notificationIsPrior.boolValue) {
            [self.tableView beginUpdates];
            return;
        }
        switch (kind) {
            case NSKeyValueChangeInsertion: {
                NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];
                [self.tableView insertSections:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case NSKeyValueChangeReplacement: {
                NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];
                [self.tableView reloadSections:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
            }
                break;
            case NSKeyValueChangeRemoval: {
                NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];
                [self.tableView deleteSections:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case NSKeyValueChangeSetting: {
                [self.tableView reloadData];
            }
            default:
                break;
        }
        [self.tableView endUpdates];
    }
}

@end
