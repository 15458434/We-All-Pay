//
//  MCReturnPaymentViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 07-02-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import FirebaseAnalytics;

#import "MCReturnPaymentViewController.h"
#import "MCSharedBillTableViewController.h"
#import "MCSharedBillPageViewController.h"

#import "MCCurrency+addons.h"
#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"
#import "MCWeAllPayStoreController.h"

#import "We_all_pay-Swift.h"

typedef NS_ENUM(BOOL, MCXRateStatus) {
    xRatesPresent NS_SWIFT_NAME(Present),
    xRatesMissing NS_SWIFT_NAME(Missing)
};

@interface MCReturnPaymentViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSArray<MCPerson *> *peoplePresent;
@property (nonatomic, strong) NSArray<ReturnPayment *> *solution;

@property (nonatomic) MCXRateStatus areXRatesMissing;

@property (nonatomic, strong) MCTableEmptyMessage *emptyMessage;

@end

@implementation MCReturnPaymentViewController

@synthesize sendMailObject;

#pragma mark - Actions

- (IBAction)sendAsEmailButtonPressed:(id)sender
{
    [FIRAnalytics logEventWithName:@"Send email pressed" parameters:nil];
    [self shareBill:self];
}

- (IBAction)mainCancelButtonPressed:(id)sender
{
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public in this class

- (void)openMailView:(id)sender
{

}

#pragma mark - Private in this class

- (void)shareBill:(id)sender
{
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

- (void)setEmptyMessageNow
{
    if ([_solution count] != 0) {
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

- (void)giveSolution
{
    [_emptyMessage.activityIndicator startAnimating];
    _areXRatesMissing = xRatesMissing;
    
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
        self.areXRatesMissing = xRatesPresent;
        self.solution = results;
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
        self->_peoplePresent = [[self->_tonightsBill peoplePresent] sortedArrayUsingDescriptors:@[sortDescriptor]];
        [[[self emptyMessage] activityIndicator] stopAnimating];
        
        [self setEmptyMessageNow];
        
        [[self tableView] beginUpdates];
        NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, 3)];
        [[self tableView] insertSections:indexes withRowAnimation:UITableViewRowAnimationTop];
        [[self tableView] endUpdates];
    }];
}

#pragma mark - New in this Class

- (void)setEmptyMessage
{
    if (!([_solution count] == 0 || _emptyMessage.activityIndicator.isAnimating)) {
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

#pragma mark - Inherited from super.

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _emptyMessage = [[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage" owner:self options:nil][0];
    
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self giveSolution];
    
    [[_emptyMessage bigMessage] setText:NSLocalizedString(@"RETURNPAYMENTSVIEW_NOPAYMENTS", @"Please add payments and/or people if you want a solution on who owes who.")];
    [[self tableView] setBackgroundView:_emptyMessage];
    [self setEmptyMessageNow];
    
    if (_tonightsBill.peoplePresent.count == 0 || _tonightsBill.payments.count == 0) {
        [[_emptyMessage bigMessage] setText:NSLocalizedString(@"RETURNPAYMENTSVIEW_NOPAYMENTS", @"Please add payments and/or people if you want a solution on who owes who.")];
    } else {
        _emptyMessage.bigMessage.text = @"";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPresentInterstitialAd
{
    return NO;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *sectionTitleHeader = (UITableViewHeaderFooterView *)view;
    [view setTintColor:[Colors getbackgroundColor]];
    [[sectionTitleHeader textLabel] setTextColor:[Colors getEmptyMessageTextColor]];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *sectionTitleHeader = (UITableViewHeaderFooterView *)view;
    [view setTintColor:nil];
    [[sectionTitleHeader textLabel] setTextColor:nil];

}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        ReturnPayment *thisCellsReturnPayment = _solution[[indexPath row]];
        MCWhoOwesWhoTableViewCell_iPhone *returnPaymentCell = [tableView dequeueReusableCellWithIdentifier:@"MCWhoOwesWhoTableViewCell_iPhone"];
        CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_tonightsBill.mainCurrency.code];
        returnPaymentCell.moneyLabel.text = [cf stringFor:thisCellsReturnPayment.money];
        
        NSString *owesString = NSLocalizedString(@"OWES", @"As in Mark owes Arjen, but then just the word owes.");
        NSString *whoOwesWho = [[NSString alloc] initWithFormat:@"%@ %@ %@:", [[thisCellsReturnPayment payer] getName], owesString, [[thisCellsReturnPayment receiver] getName]];
        [[returnPaymentCell whoOwesWhoLabel] setText:whoOwesWho];
        [returnPaymentCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return returnPaymentCell;
    }
    
    if ([indexPath section] == 1) {
        MCWhoPaidHowMuchTableViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:@"MCWhoPaidHowMuchTableViewCell_iPhone"];
        
        MCPerson *person = [_peoplePresent objectAtIndex:[indexPath row]];
        [[cell whoPaidHowMuchLabel] setText:[person getFullName]];
        NSNumber *sumSpentByPerson = @(-[[_tonightsBill amountShouldHavePaidBy:person] doubleValue]);
        CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_tonightsBill.mainCurrency.code];
        cell.moneyLabel.text = [cf stringFor:sumSpentByPerson];
        return cell;
    }
    
    if ([indexPath section] == 2) {
        if ([indexPath row] < [_peoplePresent count]) {
            MCWhoPaidHowMuchTableViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:@"MCWhoPaidHowMuchTableViewCell_iPhone"];
            
            MCPerson *person = [_peoplePresent objectAtIndex:[indexPath row]];
            [[cell whoPaidHowMuchLabel] setText:[person getFullName]];
            
            CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_tonightsBill.mainCurrency.code];
            cell.moneyLabel.text = [cf stringFor:person.totalSumPaid];
            return cell;
        } else {
            MCSolutionOverViewTableViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:@"MCSolutionOverViewTableViewCell_iPhone"];
            NSString *totalSpentString = NSLocalizedString(@"TOTAL_SPENT", @"Total spent:");
            [[cell totalLabel] setText:totalSpentString];
            
            CurrencyFormatter *cf = [[CurrencyFormatter alloc] initWithCurrencyCode:_tonightsBill.mainCurrency.code];
            cell.moneyLabel.text = [cf stringFor:_tonightsBill.totalSumOfMoneyOfThisSharedBill];
            return cell;
        }
    }
    
    return nil;
}

@end
