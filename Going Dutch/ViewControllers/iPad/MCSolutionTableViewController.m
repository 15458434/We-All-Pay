//
//  MCSolutionTableViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 11-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCSolutionTableViewController.h"

#import "We_all_pay-Swift.h"

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCPayment+addons.h"
#import "MCPerson+addons.h"
#import "MCCurrency+addons.h"

typedef NS_ENUM(BOOL, MCXRatesMissing) {
    xRatesPresent,
    xRatesMissing
};

@interface MCSolutionTableViewController ()

@property (nonatomic, strong) NSArray *solution;
@property (nonatomic, strong) MCTableEmptyMessage_iPad *emptyMessage;
@property (nonatomic) MCXRatesMissing areXRatesMissing;

@end

@implementation MCSolutionTableViewController

#pragma mark - Action

- (IBAction)mainCancelButton:(id)sender
{
    _dismissMe();
}

- (IBAction)sendEmailButtonPressed:(id)sender
{
    [self openMailView:self];
}

#pragma mark - New in this class

- (void)openMailView:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        // Init the mailComposer
        MCMailComposer *mailComposer = [[MCMailComposer alloc] initWithTonightsBill:_tonightsBill];
        
        // Init the mail ViewController
        MFMailComposeViewController *_mailViewController = [[MFMailComposeViewController alloc] init];
        [_mailViewController setMailComposeDelegate:sender];
        [_mailViewController setEdgesForExtendedLayout:UIRectEdgeNone];
        [_mailViewController setModalPresentationStyle:UIModalPresentationFormSheet];
        [[_mailViewController viewControllers][0] setEdgesForExtendedLayout:UIRectEdgeNone];
        
        NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[self navigationController].navigationBar.titleTextAttributes];
        [textAttributes setValue:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        [[_mailViewController navigationBar] setTitleTextAttributes:textAttributes];
        
        // Set the mail.
        [_mailViewController setToRecipients:[mailComposer getMailAddresses]];
        [_mailViewController setSubject:[mailComposer getSubject]];
        [_mailViewController setMessageBody:[mailComposer getMailBody] isHTML:mailComposer.isHTML];
        
        if (sender!=self) {
            [sender presentViewController:_mailViewController animated:YES completion:nil];
        } else {
            [[self navigationController] presentViewController:_mailViewController animated:YES completion:nil];
        }
    } else {
        NSString *alertTitle = NSLocalizedString(@"Unable to send email", @"Title of an alert that notifies the user the app is unable to send email.");
        NSString *alertMessage = NSLocalizedString(@"Please configure your mail in Settings", @"Instruction in an alert to tell the user that they should check their email address for a valid configuration.");
        NSString *dismiss = NSLocalizedString(@"Dismiss", @"Text on a button that dismisses the alert");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:dismiss style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:dismissAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)setEmptyMessageNow
{
    if ([_solution count] != 0) {
        [UIView animateWithDuration:0.0 animations:^{
            [[_emptyMessage bigMessage] setAlpha:0.0];
            [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        } completion:nil];
    } else {
        if ([[_emptyMessage bigMessage] alpha] < 1.0) {
            [UIView animateWithDuration:0.0 animations:^{
                [[_emptyMessage bigMessage] setAlpha:1.0];
                [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            } completion:nil];
        }
    }
}

- (void)giveSolution
{
    _solution = [_tonightsBill solveWhoHasToPayWhoFromThisBillWithHandler:^(NSArray *results, NSError *error) {
        if (error) {
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
        
        // Update tableView.
        self.areXRatesMissing = xRatesPresent;
        self.solution = results;
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
        _peoplePresent = [[self.tonightsBill peoplePresent] sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        NSLog(@"Stop animating.");
        [[[self emptyMessage] activityIndicator] stopAnimating];
        [self setEmptyMessageNow];
        [self.tableView beginUpdates];
        [[self tableView] insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationTop];
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

#pragma mark - Inherited from super

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    _emptyMessage = [[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage_iPad" owner:self options:nil][0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self giveSolution];
    if ([_tonightsBill areAllExchangeRatesValid]) {
        _areXRatesMissing = xRatesPresent;
        [[_emptyMessage activityIndicator] stopAnimating];
        [[_emptyMessage bigMessage] setHidden:NO];
    } else {
        _areXRatesMissing = xRatesMissing;
        [[_emptyMessage activityIndicator] startAnimating];
        [[_emptyMessage bigMessage] setHidden:YES];
    }
    
    [[_emptyMessage bigMessage] setText:NSLocalizedString(@"RETURNPAYMENTSVIEW_NOPAYMENTS", @"Please add payments and/or people if you want a solution on who owes who.")];
    [[self tableView] setBackgroundView:_emptyMessage];
    [self setEmptyMessageNow];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MFMailComposeViewDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultSent) {
        [self showRateMeIfNecessary];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (result == MFMailComposeResultSaved) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (result == MFMailComposeResultFailed) {
        NSLog(@"Error sending email: %@", error);
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (result == MFMailComposeResultCancelled) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    [view setTintColor:[Colors getbackgroundColor]];
    UITableViewHeaderFooterView *sectionTitleHeader = (UITableViewHeaderFooterView *)view;
    [[sectionTitleHeader textLabel] setTextColor:[Colors getEmptyMessageTextColor]];
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
    // Return the number of sections.
    if (_areXRatesMissing == xRatesMissing) {
        return 0;
    } else {
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
            @throw [NSException exceptionWithName:@"TableView broken" reason:@"There are no more than 2 sections in this tableView." userInfo:nil];
            return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
