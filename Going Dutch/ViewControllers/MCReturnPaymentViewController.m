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

static void * peoplePresentContext = &peoplePresentContext;
static void * paymentsContext = &paymentsContext;

@interface MCReturnPaymentViewController () <MCAdBannerEngineDelegate>

@property (strong, nonatomic) IBOutlet MCSolutionModel *model;

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
    _tonightsBill = event;
    [_model prepareForUseWith:event];
    self.sendMailObject = sendMailDelegate;
}

#pragma mark - Private in this class

- (void)shareBill:(id)sender {
    if ([[self tonightsBill] doesEveryoneHaveAnEmailAddress]) {
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
                [self openMailView:self];
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
    [_tonightsBill solveWithHandler:^(NSArray *results, NSError *error) {
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
        self.model.solution = results;
        [[[self emptyMessage] activityIndicator] stopAnimating];
        
        [self setEmptyMessageWithDuration:0.0];
        
        [[self tableView] beginUpdates];
        NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, 3)];
        [[self tableView] insertSections:indexes withRowAnimation:UITableViewRowAnimationTop];
        [[self tableView] endUpdates];
        completion(YES);
    }];
}

- (NSString *)adBannerUnitId {
    return @"ca-app-pub-5354415674074435/5892377702";
}

- (NSIndexSet *)adBannerSectionIndexSet {
    return [NSIndexSet indexSetWithIndex:1];
}

- (MCWhoOwesWhoTableViewCell_iPhone *)whoOwesWhoCellForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    MCReturnPayment *thisCellsReturnPayment = _model.solution[[indexPath row]];
    MCWhoOwesWhoTableViewCell_iPhone *returnPaymentCell = [tableView dequeueReusableCellWithIdentifier:@"MCWhoOwesWhoTableViewCell_iPhone"];
    CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_tonightsBill.mainCurrency.code];
    returnPaymentCell.moneyLabel.text = [cf stringForObjectValue:thisCellsReturnPayment.money];
    
    NSString *owesString = NSLocalizedStringWithDefaultValue(@"solution_view_cell_who_owes_who_label", nil, NSBundle.mainBundle, @"%1$@ owes %2$@", @"In the solution view: As in Mark owes Yvette x amount of money.");
    NSString *whoOwesWho = [NSString stringWithFormat:owesString, [thisCellsReturnPayment.payer getName], [thisCellsReturnPayment.receiver getName]];
    [[returnPaymentCell whoOwesWhoLabel] setText:whoOwesWho];
    [returnPaymentCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return returnPaymentCell;
}

- (MCWhoPaidHowMuchTableViewCell_iPhone *)whoPaidHowMuchCellForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    MCWhoPaidHowMuchTableViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:@"MCWhoPaidHowMuchTableViewCell_iPhone"];
    
    MCPerson *person = [_model.peoplePresentLocalizedSorted objectAtIndex:[indexPath row]];
    [[cell whoPaidHowMuchLabel] setText:[person getFullName]];
    NSNumber *sumSpentByPerson = @(-[[_tonightsBill amountShouldHavePaidBy:person] doubleValue]);
    CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_tonightsBill.mainCurrency.code];
    cell.moneyLabel.text = [cf stringForObjectValue:sumSpentByPerson];
    return cell;
}

- (UITableViewCell *)totalsCellForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    if (indexPath.row < _model.peoplePresentLocalizedSorted.count) {
        MCWhoPaidHowMuchTableViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:@"MCWhoPaidHowMuchTableViewCell_iPhone"];
        
        MCPerson *person = [_model.peoplePresentLocalizedSorted objectAtIndex:[indexPath row]];
        [[cell whoPaidHowMuchLabel] setText:[person getFullName]];
        
        CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_tonightsBill.mainCurrency.code];
        cell.moneyLabel.text = [cf stringForObjectValue:person.totalSumPaid];
        return cell;
    } else {
        MCSolutionOverViewTableViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:@"MCSolutionOverViewTableViewCell_iPhone"];
        NSString *totalSpentString = NSLocalizedStringWithDefaultValue(@"solution_view_cell_label_total_spent", nil, NSBundle.mainBundle, @"Total spent:", @"In the solution view: a label before the total amount of money spent on the entire event.");
        [[cell totalLabel] setText:totalSpentString];
        
        CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_tonightsBill.mainCurrency.code];
        cell.moneyLabel.text = [cf stringForObjectValue:_tonightsBill.totalSumOfMoneyOfThisSharedBill];
        return cell;
    }
}

- (void)startAdBanner {
    self.worstSalesPitchEverView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    [self.adBannerEngine prepareAdBanner:self.worstSalesPitchEverView withAdUnitId:self.adBannerUnitId andViewController:self];
}

#pragma mark - MCAdBannerEngineDelegate

- (void)adEngine:(MCAdBannerEngine *)adEngine putOnScreenBannerView:(GADBannerView *)bannerView {
    UITableView *tableView = self.tableView;
    if (containsBits(self.uiState, MCReturnPaymentViewControllerStateShowAdBanner)) {
        [tableView beginUpdates];
        [tableView reloadSections:self.adBannerSectionIndexSet withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    } else {
        self.uiState = enableBits(self.uiState, MCReturnPaymentViewControllerStateShowAdBanner);
        [tableView beginUpdates];
        [tableView insertSections:self.adBannerSectionIndexSet withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

- (void)adEngine:(MCAdBannerEngine *)adEngine putOffScreenBannerView:(GADBannerView *)bannerView {
    if (!containsBits(self.uiState, MCReturnPaymentViewControllerStateShowAdBanner)) {
        // BannerView is not on screen nothing to do.
        return;
    }
    
    self.uiState = disableBits(self.uiState, MCReturnPaymentViewControllerStateShowAdBanner);
    UITableView *tableView = self.tableView;
    [tableView beginUpdates];
    [tableView deleteSections:self.adBannerSectionIndexSet withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *sectionTitleHeader = (UITableViewHeaderFooterView *)view;
    if (@available(iOS 11.0, *)) {
        view.tintColor = [UIColor colorNamed:@"background"];
        sectionTitleHeader.textLabel.textColor = [UIColor colorNamed:@"emptyMessageText"];
    } else {
        // Fallback on earlier versions
    }
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *sectionTitleHeader = (UITableViewHeaderFooterView *)view;
    [view setTintColor:nil];
    [[sectionTitleHeader textLabel] setTextColor:nil];

}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.uiState == MCReturnPaymentViewControllerStateNone) {
        NSLog(@"No contents this shouldn't be called");
        NSParameterAssert(NO);
        return nil;
    } else if (self.uiState == MCReturnPaymentViewControllerStateXRatesPresent) {
        if (_model.solution.count > 0) {
            return [_model sectionTitleForSection:section];
        }
    } else if (self.uiState == MCReturnPaymentViewControllerStateShowAdBanner) {
        NSLog(@"Showing only a banner is useless this shouldn't happen");
        NSParameterAssert(NO);
        return nil;
    } else if (self.uiState == (MCReturnPaymentViewControllerStateShowAdBanner | MCReturnPaymentViewControllerStateXRatesPresent)) {
        if (_model.solution.count > 0) {
            switch (section) {
                case 0:
                    return [_model sectionTitleForSection:section];
                case 1:
                    return nil;
                case 2: {
                    NSUInteger adaptedSectionNumber = section - 1;
                    return [_model sectionTitleForSection:adaptedSectionNumber];
                }
                case 3: {
                    NSUInteger adaptedSectionNumber = section - 1;
                    return [_model sectionTitleForSection:adaptedSectionNumber];
                }
                default:
                    return nil;
            }
        }
    } else {
        NSLog(@"This value shouldn't exist");
        NSParameterAssert(NO);
        return 0;
    }

    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.uiState == MCReturnPaymentViewControllerStateNone) {
        return 0;
    } else if (self.uiState == MCReturnPaymentViewControllerStateXRatesPresent) {
        if (_model.solution == nil) {
            return 0;
        } else {
            return 3;
        }
    } else if (self.uiState == MCReturnPaymentViewControllerStateShowAdBanner) {
        return 0;
    } else if (self.uiState == (MCReturnPaymentViewControllerStateShowAdBanner | MCReturnPaymentViewControllerStateXRatesPresent)) {
        if (_model.solution == nil) {
            return 0;
        } else {
            return 4;
        }
    } else {
        NSLog(@"This value shouldn't exist");
        NSParameterAssert(NO);
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.uiState == MCReturnPaymentViewControllerStateNone) {
        NSLog(@"No tableview contents");
        NSParameterAssert(NO);
        return 0;
    } else if (self.uiState == MCReturnPaymentViewControllerStateXRatesPresent) {
        switch (section) {
            case 0:
                return _model.solution.count;
            case 1:
                if (_model.solution.count == 0) {
                    return 0;
                } else {
                    return _model.peoplePresentLocalizedSorted.count;
                }
            case 2:
                if (_model.solution.count == 0) {
                    return 0;
                } else {
                    return _model.peoplePresentLocalizedSorted.count + 1;
                }
            default:
                return 0;
        }
    } else if (self.uiState == MCReturnPaymentViewControllerStateShowAdBanner) {
        NSLog(@"No tableview contents");
        NSParameterAssert(NO);
        return 0;
    } else if (self.uiState == (MCReturnPaymentViewControllerStateShowAdBanner | MCReturnPaymentViewControllerStateXRatesPresent)) {
        switch (section) {
            case 0:
                return _model.solution.count;
            case 1:
                return 1;
            case 2:
                if (_model.solution.count == 0) {
                    return 0;
                } else {
                    return _model.peoplePresentLocalizedSorted.count;
                }
            case 3:
                if (_model.solution.count == 0) {
                    return 0;
                } else {
                    return _model.peoplePresentLocalizedSorted.count + 1;
                }
            default:
                return 0;
        }
    } else {
        NSLog(@"This value shouldn't exist");
        NSParameterAssert(NO);
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.uiState == MCReturnPaymentViewControllerStateNone) {
        NSLog(@"This value shouldn't exist");
        NSParameterAssert(NO);
    } else if (self.uiState == MCReturnPaymentViewControllerStateXRatesPresent) {
        switch (indexPath.section) {
            case 0:
                return [self whoOwesWhoCellForIndexPath:indexPath inTableView:tableView];
            case 1:
                return [self whoPaidHowMuchCellForIndexPath:indexPath inTableView:tableView];
            case 2:
                return [self totalsCellForIndexPath:indexPath inTableView:tableView];
            default:
                NSParameterAssert(NO);
        }
    } else if (self.uiState == MCReturnPaymentViewControllerStateShowAdBanner) {
        NSLog(@"This value shouldn't exist");
        NSParameterAssert(NO);
    } else if (self.uiState == (MCReturnPaymentViewControllerStateShowAdBanner | MCReturnPaymentViewControllerStateXRatesPresent)) {
        switch (indexPath.section) {
            case 0:
                return [self whoOwesWhoCellForIndexPath:indexPath inTableView:tableView];
            case 1:
            {
                MCAdBannerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MCAdBannerTableViewCell" forIndexPath:indexPath];
                [cell updateBannerView:_worstSalesPitchEverView];
                return cell;
            }
            case 2:
                return [self whoPaidHowMuchCellForIndexPath:indexPath inTableView:tableView];
            case 3:
                return [self totalsCellForIndexPath:indexPath inTableView:tableView];
            default:
                NSParameterAssert(NO);
        }
    } else {
        NSLog(@"This value shouldn't exist");
        NSParameterAssert(NO);
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    __weak typeof(self) weakSelf = self;
    [self giveSolutionWithCompletion:^(BOOL success) {
        if (success && (self.model.solution.count > 0)) {
            [weakSelf startAdBanner];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _emptyMessage.topConstraint.constant = self.headerView.frame.size.height;
    
    // Create KVO
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;
    [self.model addObserver:self forKeyPath:@"peoplePresentLocalizedSorted" options:options context:peoplePresentContext];
    [self.model.event addObserver:self forKeyPath:@"payments" options:options context:paymentsContext];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Destroy KVO
    [self.model removeObserver:self forKeyPath:@"peoplePresentLocalizedSorted" context:peoplePresentContext];
    [self.model.event removeObserver:self forKeyPath:@"payments" context:paymentsContext];
}

#pragma mark - UIResponder

#pragma mark - NSObject

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == peoplePresentContext) {
        NSNumber *changeKeyNumber = (NSNumber *)change[NSKeyValueChangeKindKey];
        NSKeyValueChange keyValueChange = changeKeyNumber.unsignedIntegerValue;
        switch (keyValueChange) {
            case NSKeyValueChangeSetting: {
                id new = change[NSKeyValueChangeNewKey];
                if ([new isKindOfClass:[NSSet class]]) {
                    [self setEmptyMessageWithDuration:0.0];
                } else {
                    [self setEmptyMessageWithDuration:0.0];
                }
            }
                break;
            default:
                break;
        }
    } else if (context == paymentsContext) {
        NSNumber *changeKeyNumber = (NSNumber *)change[NSKeyValueChangeKindKey];
        NSKeyValueChange keyValueChange = changeKeyNumber.unsignedIntegerValue;
        switch (keyValueChange) {
            case NSKeyValueChangeSetting: {
                id new = change[NSKeyValueChangeNewKey];
                if ([new isKindOfClass:[NSSet class]]) {
                    [self setEmptyMessageWithDuration:0.0];
                } else {
                    [self setEmptyMessageWithDuration:0.0];
                }
            }
                break;
            default:
                break;
        }
    }
}

@end
