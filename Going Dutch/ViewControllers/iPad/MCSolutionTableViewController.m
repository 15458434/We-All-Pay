//
//  MCSolutionTableViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 11-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCSolutionTableViewController.h"

#import "MCWhoOwesWhoTableViewCell_iPad.h"
#import "MCSolutionOverViewTableViewCell_iPad.h"
#import "MCTableEmptyMessage_iPad.h"

#import "MCMailComposer.h"

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCPayment+addons.h"
#import "MCPerson+addons.h"
#import "MCReturnPayment.h"

@interface MCSolutionTableViewController ()

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
    // Init the mailComposer
    MCMailComposer *mailComposer = [[MCMailComposer alloc] init];
    [mailComposer setTonightsBill:_tonightsBill];
    [mailComposer setIsHTML:NO];
    [mailComposer setSolution:_solution];
    
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
    [_mailViewController setMessageBody:[mailComposer getMailBody] isHTML:NO];
    
    if (sender!=self) {
        [sender presentViewController:_mailViewController animated:YES completion:nil];
    } else {
        [[self navigationController] presentViewController:_mailViewController animated:YES completion:nil];
    }
}

- (void)setEmptyMessageNow
{
    if (![_solution count] == 0) {
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
    
    _solution = [_tonightsBill solveWhoHasToPayWhoFromThisBill];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    _peoplePresent = [[_tonightsBill peoplePresent] sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    emptyMessage = [[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage_iPad" owner:self options:nil][0];
    [[emptyMessage bigMessage] setText:NSLocalizedString(@"RETURNPAYMENTSVIEW_NOPAYMENTS", @"Please add payments and/or people if you want a solution on who owes who.")];
    [[self tableView] setBackgroundView:emptyMessage];
    [self setEmptyMessageNow];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"MCSolutionScreen_iPad"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
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
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (result == MFMailComposeResultSaved) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (result == MFMailComposeResultFailed) {
        NSLog(@"Error sending email: %@", [error localizedDescription]);
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (result == MFMailComposeResultCancelled) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    [view setTintColor:[MCColors getbackgroundColor]];
    UITableViewHeaderFooterView *sectionTitleHeader = (UITableViewHeaderFooterView *)view;
    [[sectionTitleHeader textLabel] setTextColor:[MCColors getEmptyMessageTextColor]];
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
    return 3;
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
        MCWhoOwesWhoTableViewCell_iPad *cell = [tableView dequeueReusableCellWithIdentifier:@"MCWhoOwesWhoTableViewCell_iPad" forIndexPath:indexPath];
        
        // Configure the cell...
        MCReturnPayment *thisCellContents = [_solution objectAtIndex:[indexPath row]];
        
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
        NSNumber *moneyToConvert = [thisCellContents money];
        [[cell moneyLabel] setText:[nf stringFromNumber:moneyToConvert]];
        
        NSString *owesString = NSLocalizedString(@"OWES", @"As in Mark owes Arjen, but then just the word owes.");
        NSString *whoOwesWho = [[NSString alloc] initWithFormat:@"%@ %@ %@:", [[thisCellContents payer] getFullName], owesString, [[thisCellContents receiver] getFullName]];
        [[cell whoOwesWhoLabel] setText:whoOwesWho];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    
    if ([indexPath section] == 1) {
        MCSolutionOverViewTableViewCell_iPad *cell = [tableView dequeueReusableCellWithIdentifier:@"MCSolutionOverViewTableViewCell_iPad" forIndexPath:indexPath];
        
        NSString *eachPaysString = NSLocalizedString(@"EACH_USED", @"Each used:");
        NSString *thisPersonPaidString = [NSString stringWithFormat:@"%@ %@", [[_peoplePresent objectAtIndex:[indexPath row]] getFullName], eachPaysString];
        [[cell firstLabel] setText:thisPersonPaidString];
        MCPerson *thisPerson = [_peoplePresent objectAtIndex:[indexPath row]];
        NSNumber *sumSpentByPerson = @(-[[_tonightsBill amountShouldHavePaidBy:thisPerson] doubleValue]);
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        [nf setLocale:[NSLocale currentLocale]];
        [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
        [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
        [[cell lastLabel] setText:[nf stringFromNumber:sumSpentByPerson]];

        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    
    if ([indexPath section] == 2) {
        MCSolutionOverViewTableViewCell_iPad *cell = [tableView dequeueReusableCellWithIdentifier:@"MCSolutionOverViewTableViewCell_iPad" forIndexPath:indexPath];
        
        if ([indexPath row] < [_peoplePresent count]) {
            NSString *paidString = NSLocalizedString(@"TOTAL_PAID", @"total paid:");
            NSString *thisPersonPaidString = [NSString stringWithFormat:@"%@ %@", [[_peoplePresent objectAtIndex:[indexPath row]] getFullName], paidString];
            [[cell firstLabel] setText:thisPersonPaidString];
            MCPerson *thisPerson = [_peoplePresent objectAtIndex:[indexPath row]];
            NSNumber *sumSpentByPerson = [_tonightsBill totalSumPaidBy:thisPerson];
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setLocale:[NSLocale currentLocale]];
            [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
            [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
            [[cell lastLabel] setText:[nf stringFromNumber:sumSpentByPerson]];
        } else {
            NSString *totalSpentString = NSLocalizedString(@"TOTAL_SPENT", @"Total spent:");
            [[cell firstLabel] setText:totalSpentString];
            [[cell lastLabel] setText:[_tonightsBill totalSumOfMoneyOfThisSharedBillAsCurrencyString]];
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
