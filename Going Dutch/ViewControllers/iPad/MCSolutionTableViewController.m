//
//  MCSolutionTableViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 11-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import FirebaseAnalytics;

#import "MCSolutionTableViewController.h"

#import "We_all_pay-Swift.h"

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCPayment+addons.h"
#import "MCPerson+addons.h"
#import "MCCurrency+addons.h"

typedef NS_ENUM(BOOL, MCXRateStatus) {
    xRatesPresent NS_SWIFT_NAME(Present),
    xRatesMissing NS_SWIFT_NAME(Missing)
};

@interface MCSolutionTableViewController ()

@property (nonatomic, strong) NSArray *solution;

@property (nonatomic, strong) MCTableEmptyMessage *emptyMessage;
@property (weak, nonatomic) IBOutlet UITableViewHeaderFooterView *headerView;

@property (nonatomic) MCXRateStatus areXRatesMissing;

@end

@implementation MCSolutionTableViewController

#pragma mark - IBAction

- (IBAction)mainCancelButton:(id)sender {
    if (_solution == nil || _solution.count == 0) {
        _dismissMe();
    } else if (self.adEngine.interstitialAd.isReady) {
        NSError *adError;
        [self.adEngine putOnScreenIfAvailableWithPresentingViewController:self error:&adError];
        if (adError) {
            NSLog(@"Error: Unable to show interstitial: %@", adError);
            _dismissMe();
        }
    } else {
        _dismissMe();
    }
}

- (IBAction)sendEmailButtonPressed:(id)sender {
    [self openMailView:self];
}

#pragma mark - New in this class

- (void)openMailView:(id)sender
{

}

- (void)setEmptyMessageWithDuration:(NSTimeInterval)duration {
    if (_solution.count != 0) {
        [UIView animateWithDuration:duration animations:^{
            self.emptyMessage.bigMessage.alpha = 0.0;
            self.emptyMessage.borderlineView.alpha = 0.0;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        } completion:nil];
    } else if (!_solution) {
        [UIView animateWithDuration:duration animations:^{
            self.emptyMessage.bigMessage.alpha = 1.0;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        } completion:nil];
    } else {
        if ([[_emptyMessage bigMessage] alpha] < 1.0) {
            [UIView animateWithDuration:duration animations:^{
                self.emptyMessage.bigMessage.alpha = 1.0;
                self.emptyMessage.borderlineView.alpha = 1.0;
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            } completion:nil];
        }
    }
}

- (void)giveSolution
{
    [_tonightsBill solveWithHandler:^(NSArray *results, NSError *error) {
        if (error) {
            NSString *title = NSLocalizedString(@"Unable to fetch exchange rates", @"Title message of an alert that pops up when fetching exchange rates is impossible");
            NSString *message = NSLocalizedString(@"Fetching exchange rates is not possible at this moment. Check your internet connection and/or hit solve to fetch all missing exchange rates at a later time", @"Message explaining what the user can do to refetch exchange rates");
            NSString *dismissTitle = NSLocalizedString(@"Dismiss", @"Title of a button that dismisses an alert.");
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:dismissTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self.emptyMessage.activityIndicator stopAnimating];
                self.emptyMessage.bigMessage.text = message;
                [self setEmptyMessageWithDuration:0.3];
            }];
            [alertController addAction:dismissAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
            return;
        }
        
        // Workaround for a bug in iOS 9. Call reloadData before calling beginUpdates
        if (@available(iOS 9.0, *)) {
            BOOL shouldReloadData = YES;
            NSInteger numberOfSections = [self.tableView.dataSource numberOfSectionsInTableView:self.tableView];
            for (NSInteger section = 0; section < numberOfSections; section++)
            {
                if ([self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:section] > 0)
                {
                    // found a row in current section, do not need to reload data
                    shouldReloadData = NO;
                    break;
                }
            }
            
            if (shouldReloadData)
            {
                [self.tableView reloadData];
            }
        }
        
        // Update tableView.
        [self.tableView beginUpdates];
        
        self.areXRatesMissing = xRatesPresent;
        self.solution = results;
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
        self->_peoplePresent = [[self.tonightsBill peoplePresent] sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        NSLog(@"Stop animating.");
        [[[self emptyMessage] activityIndicator] stopAnimating];
        [self setEmptyMessageWithDuration:0.0];
        
        NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, 3)];
        [[self tableView] insertSections:indexes withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }];
    
    if (!_solution) {
        NSLog(@"Start animating");
        [_emptyMessage.activityIndicator startAnimating];
    } else {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
        _peoplePresent = [[_tonightsBill peoplePresent] sortedArrayUsingDescriptors:@[sortDescriptor]];
    }
}

- (void)updateAdEngine:(MCInterstitialAdEngine *)adEngine andEvent:(MCSharedBill *)event andDismissBlock:(void (^)(void))dismissMe {
    self.adEngine = adEngine;
    self.loadInterstitialOnViewDidLoad = YES;
    self.tonightsBill = event;
    self.dismissMe = dismissMe;
}

#pragma mark - MCGenericInterstitialAdTableViewController

- (NSString *)adUnitId {
#ifdef DEBUG
    return @"ca-app-pub-3940256099942544/4411468910";
#else
    return @"ca-app-pub-5354415674074435/1117722855";
#endif
}

#pragma mark - MCInterstitialAdEngineDelegate

- (void)willDismissInterstatialFor:(MCInterstitialAdEngine *)adEngine {
    _dismissMe();
}

#pragma mark - UITableViewController

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return [_solution count];
        case 1:
            if ([_solution count] == 0) {
                return 0;
            } else {
                return [_peoplePresent count];
            }
        case 2:
            if ([_solution count] == 0) {
                return 0;
            } else {
                return [_peoplePresent count] + 1;
            }
        default:
            @throw [NSException exceptionWithName:@"TableView broken" reason:@"There are no more than 3 sections in this tableView." userInfo:nil];
            return -1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (_areXRatesMissing == xRatesMissing) {
#ifdef DEBUG
        NSLog(@"Amount of sections is 0.");
#endif
        return 0;
    } else if (_solution == nil) {
#ifdef DEBUG
        NSLog(@"Amount of sections is 0.");
#endif
        return 0;
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        WhoOwesWhoTableViewCell_iPad *cell = [tableView dequeueReusableCellWithIdentifier:@"MCWhoOwesWhoTableViewCell_iPad" forIndexPath:indexPath];
        
        // Configure the cell...
        ReturnPayment *thisCellContents = [_solution objectAtIndex:[indexPath row]];
        
        CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_tonightsBill.mainCurrency.code];
        cell.moneyLabel.text = [cf stringForObjectValue:thisCellContents.money];
        
        NSString *owesString = NSLocalizedString(@"OWES", @"As in Mark owes Arjen, but then just the word owes.");
        NSString *whoOwesWho = [[NSString alloc] initWithFormat:@"%@ %@ %@:", [[thisCellContents payer] getFullName], owesString, [[thisCellContents receiver] getFullName]];
        [[cell whoOwesWhoLabel] setText:whoOwesWho];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    
    if ([indexPath section] == 1) {
        SolutionOverViewTableViewCell_iPad *cell = [tableView dequeueReusableCellWithIdentifier:@"MCSolutionOverViewTableViewCell_iPad" forIndexPath:indexPath];
        
        NSString *eachPaysString = NSLocalizedString(@"EACH_USED", @"Each used:");
        NSString *thisPersonPaidString = [NSString stringWithFormat:@"%@ %@", [[_peoplePresent objectAtIndex:[indexPath row]] getFullName], eachPaysString];
        [[cell firstLabel] setText:thisPersonPaidString];
        MCPerson *thisPerson = [_peoplePresent objectAtIndex:[indexPath row]];
        NSNumber *sumSpentByPerson = @(-[[_tonightsBill amountShouldHavePaidBy:thisPerson] doubleValue]);

        CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_tonightsBill.mainCurrency.code];
        cell.lastLabel.text = [cf stringForObjectValue:sumSpentByPerson];

        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    
    if ([indexPath section] == 2) {
        SolutionOverViewTableViewCell_iPad *cell = [tableView dequeueReusableCellWithIdentifier:@"MCSolutionOverViewTableViewCell_iPad" forIndexPath:indexPath];
        
        if ([indexPath row] < [_peoplePresent count]) {
            NSString *paidString = NSLocalizedString(@"TOTAL_PAID", @"total paid:");
            NSString *thisPersonPaidString = [NSString stringWithFormat:@"%@ %@", [[_peoplePresent objectAtIndex:[indexPath row]] getFullName], paidString];
            [[cell firstLabel] setText:thisPersonPaidString];
            MCPerson *thisPerson = [_peoplePresent objectAtIndex:[indexPath row]];
            NSNumber *sumSpentByPerson = thisPerson.totalSumPaid;
            
            CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_tonightsBill.mainCurrency.code];
            cell.lastLabel.text = [cf stringForObjectValue:sumSpentByPerson];
            
        } else {
            NSString *totalSpentString = NSLocalizedString(@"TOTAL_SPENT", @"Total spent:");
            [[cell firstLabel] setText:totalSpentString];
            
            CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_tonightsBill.mainCurrency.code];
            cell.lastLabel.text = [cf stringForObjectValue:_tonightsBill.totalSumOfMoneyOfThisSharedBill];
        }

        return cell;
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
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
    return nil;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];
    
    _emptyMessage = [[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage" owner:self options:nil][0];
    self.tableView.backgroundView = _emptyMessage;
}

- (void)viewDidLoad {
    MCRemoteConfigEngine *configEngine = [[MCRemoteConfigEngine alloc] init];
    self.adEngine.shouldShowEngine = [[MCRemoteConfigTrueCasino alloc] initWithEngine:configEngine andRemoteConfigItem:ConfigEngineItemPercentageOfTimeShowAfterSolveInterstitialOniPad];
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self giveSolution];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([_tonightsBill areAllExchangeRatesValid]) {
        _areXRatesMissing = xRatesPresent;
        [[_emptyMessage activityIndicator] stopAnimating];
        [self setEmptyMessageWithDuration:0.0];
    } else {
        _areXRatesMissing = xRatesMissing;
        [[_emptyMessage activityIndicator] startAnimating];
        [self setEmptyMessageWithDuration:0.0];
    }
    
    if (_tonightsBill.peoplePresent.count == 0 || _tonightsBill.payments.count == 0) {
        [[_emptyMessage bigMessage] setText:NSLocalizedString(@"RETURNPAYMENTSVIEW_NOPAYMENTS", @"Please add payments and/or people if you want a solution on who owes who.")];
    } else {
        _emptyMessage.bigMessage.text = @"";
    }

    _emptyMessage.topConstraint.constant = _headerView.frame.size.height + self.navigationController.navigationBar.frame.size.height + 10;
    [self setEmptyMessageWithDuration:0.0];
}

#pragma mark - UIResponder

#pragma mark - NSObject

@end
