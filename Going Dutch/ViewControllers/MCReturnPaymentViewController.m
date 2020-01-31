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
#import "MCSharedBillTableViewController.h"
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

@interface MCReturnPaymentViewController () <MCAdBannerEngineDelegate>

@property (nonatomic, strong) NSArray<MCPerson *> *peoplePresent;
@property (nonatomic, strong) NSArray<ReturnPayment *> *solution;

@property (nonatomic) MCReturnPaymentViewControllerState uiState;

@property (nonatomic, strong) MCTableEmptyMessage *emptyMessage;

// Ad Banner
@property (strong, nonatomic) DFPBannerView *worstSalesPitchEverView;
@property (strong, nonatomic) IBOutlet MCAdBannerEngine *adBannerEngine;
@property (nonatomic, readonly) NSString *adBannerUnitId;
@property (nonatomic) NSIndexSet *adBannerSectionIndexSet;

@end

@implementation MCReturnPaymentViewController

@synthesize sendMailObject;

#pragma mark - Actions

- (IBAction)sendAsEmailButtonPressed:(id)sender {
    [FIRAnalytics logEventWithName:@"Send email pressed" parameters:nil];
    [self shareBill:self];
}

- (IBAction)mainCancelButtonPressed:(id)sender {
    if (_solution == nil || _solution.count == 0) {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else if (self.adEngine.interstitialAd.isReady) {
        NSError *adError;
        [self.adEngine putOnScreenIfAvailableWithPresentingViewController:self error:&adError];
        if (adError) {
            NSLog(@"Error show interstitial: %@", adError);
            [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Public in this class

- (void)openMailView:(id)sender
{

}

- (void)updateEvent:(MCSharedBill *)event andSendMailDelegate:(MCSharedBillPageViewController *)sendMailDelegate andAdEngine:(MCInterstitialAdEngine *)adEngine {
    _tonightsBill = event;
    self.sendMailObject = sendMailDelegate;
    self.loadInterstitialOnViewDidLoad = YES;
    self.adEngine = adEngine;
}

#pragma mark - Private in this class

- (void)shareBill:(id)sender {
    if ([[self tonightsBill] doesEveryoneHaveAnEmailAddress]) {
        [self openMailView:sender];
    } else {
        NSLog(@"Not everyone has an email address");
        NSString *title = NSLocalizedString(@"EMAIL_CONSTRUCTION_FAILURE_TITLE", @"Unable to send email to all people.");
        NSString *message = NSLocalizedString(@"EMAIL_CONSTRUCTION_FAILURE_MESSAGE", @"Reason: Not all people have a mail address.");
        NSString *cancel = NSLocalizedString(@"Cancel", @"Text on button to cancel something");
        NSString *sendAnyway = NSLocalizedString(@"SEND_ANYWAY", @"Send anyway");
        
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

- (void)setEmptyMessageNow {
    if (_solution.count != 0) {
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
            NSString *title = NSLocalizedString(@"Unable to fetch exchange rates", @"Title message of an alert that pops up when fetching exchange rates is impossible");
            NSString *message = NSLocalizedString(@"Fetching exchange rates is not possible at this moment. Check your internet connection and/or hit solve to fetch all missing exchange rates at a later time", @"Message explaining what the user can do to refetch exchange rates");
            NSString *dismissTitle = NSLocalizedString(@"Dismiss", @"Title of a button that dismisses an alert.");
            
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
        self.solution = results;
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
        self.peoplePresent = [[self.tonightsBill peoplePresent] sortedArrayUsingDescriptors:@[sortDescriptor]];
        [[[self emptyMessage] activityIndicator] stopAnimating];
        
        [self setEmptyMessageNow];
        
        [[self tableView] beginUpdates];
        NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, 3)];
        [[self tableView] insertSections:indexes withRowAnimation:UITableViewRowAnimationTop];
        [[self tableView] endUpdates];
        completion(YES);
    }];
}

- (void)setEmptyMessage {
    if (!(_solution.count == 0 || _emptyMessage.activityIndicator.isAnimating)) {
        [UIView animateWithDuration:1.0 animations:^{
            [[self->_emptyMessage bigMessage] setAlpha:0.0];
            [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        } completion:nil];
    } else {
        [UIView animateWithDuration:1.0 animations:^{
            [[self->_emptyMessage bigMessage] setAlpha:1.0];
            [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        } completion:nil];
    }
}

- (NSString *)adBannerUnitId {
#ifdef DEBUG
    // This is a test Unit ID for banner from Google themselves.
    return @"ca-app-pub-3940256099942544/2934735716";
#else
    return @"ca-app-pub-5354415674074435/5892377702";
#endif
}

- (NSIndexSet *)adBannerSectionIndexSet {
    return [NSIndexSet indexSetWithIndex:1];
}

- (MCWhoOwesWhoTableViewCell_iPhone *)whoOwesWhoCellForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    ReturnPayment *thisCellsReturnPayment = _solution[[indexPath row]];
    MCWhoOwesWhoTableViewCell_iPhone *returnPaymentCell = [tableView dequeueReusableCellWithIdentifier:@"MCWhoOwesWhoTableViewCell_iPhone"];
    CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_tonightsBill.mainCurrency.code];
    returnPaymentCell.moneyLabel.text = [cf stringForObjectValue:thisCellsReturnPayment.money];
    
    NSString *owesString = NSLocalizedString(@"OWES", @"As in Mark owes Arjen, but then just the word owes.");
    NSString *whoOwesWho = [[NSString alloc] initWithFormat:@"%@ %@ %@:", [[thisCellsReturnPayment payer] getName], owesString, [[thisCellsReturnPayment receiver] getName]];
    [[returnPaymentCell whoOwesWhoLabel] setText:whoOwesWho];
    [returnPaymentCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return returnPaymentCell;
}

- (MCWhoPaidHowMuchTableViewCell_iPhone *)whoPaidHowMuchCellForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    MCWhoPaidHowMuchTableViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:@"MCWhoPaidHowMuchTableViewCell_iPhone"];
    
    MCPerson *person = [_peoplePresent objectAtIndex:[indexPath row]];
    [[cell whoPaidHowMuchLabel] setText:[person getFullName]];
    NSNumber *sumSpentByPerson = @(-[[_tonightsBill amountShouldHavePaidBy:person] doubleValue]);
    CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_tonightsBill.mainCurrency.code];
    cell.moneyLabel.text = [cf stringForObjectValue:sumSpentByPerson];
    return cell;
}

- (UITableViewCell *)totalsCellForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    if (indexPath.row < _peoplePresent.count) {
        MCWhoPaidHowMuchTableViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:@"MCWhoPaidHowMuchTableViewCell_iPhone"];
        
        MCPerson *person = [_peoplePresent objectAtIndex:[indexPath row]];
        [[cell whoPaidHowMuchLabel] setText:[person getFullName]];
        
        CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_tonightsBill.mainCurrency.code];
        cell.moneyLabel.text = [cf stringForObjectValue:person.totalSumPaid];
        return cell;
    } else {
        MCSolutionOverViewTableViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:@"MCSolutionOverViewTableViewCell_iPhone"];
        NSString *totalSpentString = NSLocalizedString(@"TOTAL_SPENT", @"Total spent:");
        [[cell totalLabel] setText:totalSpentString];
        
        CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_tonightsBill.mainCurrency.code];
        cell.moneyLabel.text = [cf stringForObjectValue:_tonightsBill.totalSumOfMoneyOfThisSharedBill];
        return cell;
    }
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

#pragma mark - MCGenericInterstitialAdTableViewController

- (NSString *)adUnitId {
#ifdef DEBUG
    return @"ca-app-pub-3940256099942544/4411468910";
#else
    return @"ca-app-pub-5354415674074435/8899635256";
#endif
}

#pragma mark - MCInterstitialAdEngineDelegate

- (void)willDismissInterstatialFor:(MCInterstitialAdEngine *)adEngine {
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _emptyMessage = [[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage" owner:self options:nil][0];
    
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    [self giveSolutionWithCompletion:^(BOOL success) {
        if (success && (self.solution.count > 0)) {
            self.worstSalesPitchEverView = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeBanner];
            [self.adBannerEngine prepareAdBanner:self.worstSalesPitchEverView withAdUnitId:self.adBannerUnitId andViewController:self];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[_emptyMessage bigMessage] setText:NSLocalizedString(@"RETURNPAYMENTSVIEW_NOPAYMENTS", @"Please add payments and/or people if you want a solution on who owes who.")];
    [[self tableView] setBackgroundView:_emptyMessage];
    [self setEmptyMessageNow];
    
    if (_tonightsBill.peoplePresent.count == 0 || _tonightsBill.payments.count == 0) {
        [[_emptyMessage bigMessage] setText:NSLocalizedString(@"RETURNPAYMENTSVIEW_NOPAYMENTS", @"Please add payments and/or people if you want a solution on who owes who.")];
    } else {
        _emptyMessage.bigMessage.text = @"";
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *sectionTitleHeader = (UITableViewHeaderFooterView *)view;
    view.tintColor = [UIColor colorNamed:@"background"];
    sectionTitleHeader.textLabel.textColor = [UIColor colorNamed:@"emptyMessageText"];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *sectionTitleHeader = (UITableViewHeaderFooterView *)view;
    [view setTintColor:nil];
    [[sectionTitleHeader textLabel] setTextColor:nil];

}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.uiState == MCReturnPaymentViewControllerStateNone) {
        NSLog(@"No contents this shouldn't be called");
        NSParameterAssert(NO);
        return nil;
    } else if (self.uiState == MCReturnPaymentViewControllerStateXRatesPresent) {
        if ([_solution count] > 0) {
            switch (section) {
                case 0:
                    return NSLocalizedString(@"SOLUTION_SECTION_WHO_OWES_WHO", @"Who ows who");
                case 1:
                    return NSLocalizedString(@"SOLUTION_SECTION_TOTAL_OWES", @"Total owes");
                case 2:
                    return NSLocalizedString(@"SOLUTION_SECTION_TOTAL_PAID", @"Total paid");
                default:
                    return nil;
            }
        }
    } else if (self.uiState == MCReturnPaymentViewControllerStateShowAdBanner) {
        NSLog(@"Showing only a banner is useless this shouldn't happen");
        NSParameterAssert(NO);
        return nil;
    } else if (self.uiState == (MCReturnPaymentViewControllerStateShowAdBanner | MCReturnPaymentViewControllerStateXRatesPresent)) {
        if ([_solution count] > 0) {
            switch (section) {
                case 0:
                    return NSLocalizedString(@"SOLUTION_SECTION_WHO_OWES_WHO", @"Who ows who");
                case 1:
                    return nil;
                case 2:
                    return NSLocalizedString(@"SOLUTION_SECTION_TOTAL_OWES", @"Total owes");
                case 3:
                    return NSLocalizedString(@"SOLUTION_SECTION_TOTAL_PAID", @"Total paid");
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
        if (_solution == nil) {
            return 0;
        } else {
            return 3;
        }
    } else if (self.uiState == MCReturnPaymentViewControllerStateShowAdBanner) {
        return 0;
    } else if (self.uiState == (MCReturnPaymentViewControllerStateShowAdBanner | MCReturnPaymentViewControllerStateXRatesPresent)) {
        if (_solution == nil) {
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
                return _solution.count;
            case 1:
                if (_solution.count == 0) {
                    return 0;
                } else {
                    return _peoplePresent.count;
                }
            case 2:
                if (_solution.count == 0) {
                    return 0;
                } else {
                    return _peoplePresent.count + 1;
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
                return _solution.count;
            case 1:
                return 1;
            case 2:
                if (_solution.count == 0) {
                    return 0;
                } else {
                    return _peoplePresent.count;
                }
            case 3:
                if (_solution.count == 0) {
                    return 0;
                } else {
                    return _peoplePresent.count + 1;
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

@end
