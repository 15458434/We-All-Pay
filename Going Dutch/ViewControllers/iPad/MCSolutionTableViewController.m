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

#import "MCWeAllPayStoreController.h"
#import "MCSharedBill+addons.h"
#import "MCPayment+addons.h"
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
    MFMailComposeViewController *_mailViewController = [[MFMailComposeViewController alloc] init];
    [_mailViewController setMailComposeDelegate:sender];
    [_mailViewController setEdgesForExtendedLayout:UIRectEdgeNone];
    [_mailViewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [[_mailViewController viewControllers][0] setEdgesForExtendedLayout:UIRectEdgeNone];
    
    NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[self navigationController].navigationBar.titleTextAttributes];
    [textAttributes setValue:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [[_mailViewController navigationBar] setTitleTextAttributes:textAttributes];
    
    NSArray *sda = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    NSArray *allPeople = [[[self tonightsBill] peoplePresent] sortedArrayUsingDescriptors:sda];
    // Create a list of all email addresses
    NSMutableArray *listOfMailAddresses = [[NSMutableArray alloc] init];
    for (MCPerson *p in allPeople) {
        if ([p defaultEmailAddress]) {
            [listOfMailAddresses addObject:[p defaultEmailAddress]];
        }
    }
    // Set the mail header.
    [_mailViewController setToRecipients:listOfMailAddresses];
    NSString *subject1 = NSLocalizedString(@"EMAIL_SUBJECT_PART_ONE", @"Bill overview of our trip to %@");
    [_mailViewController setSubject:[[NSString alloc] initWithFormat:@"%@ %@.", subject1, [[self tonightsBill] tripName]]];
    
    // Generate the text for the email.
    NSMutableString *mailBody = [[NSMutableString alloc] init];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [mailBody appendFormat:@"%@ %@,\n", NSLocalizedString(@"EMAIL_DEAR", @"Just Dear as in \"Dear Mark\""), [[self tonightsBill] stringOfApproxPeoplePresent]];
    [mailBody appendFormat:@"\n"];
    NSString *intro1 = NSLocalizedString(@"EMAIL_INTRO_PART_ONE", @"From a total of \"$ 20,45\", which was spend on our last trip to \"Movies\". We all have to pay an equal share of \"$6,82\".");
    NSString *intro2 = NSLocalizedString(@"EMAIL_INTRO_PART_TWO", @"From a total of \"$ 20,45\", which was spend on our last trip to \"Movies\". We all have to pay an equal share of \"$6,82\".");
    NSString *intro3 = NSLocalizedString(@"EMAIL_INTRO_PART_THREE", @"From a total of \"$ 20,45\", which was spend on our last trip to \"Movies\". We all have to pay an equal share of \"$6,82\".");
    [mailBody appendFormat:@"%@ %@, %@ %@. %@ %@.\n", intro1, [nf stringFromNumber:[[self tonightsBill] totalSumOfMoneyOfThisSharedBill]], intro2,[[self tonightsBill] tripName], intro3, [nf stringFromNumber:[[self tonightsBill] amountPeopleShouldHavePaid]]];
    [mailBody appendFormat:@"\n"];
    if ([[self tonightsBill] totalAmountOfPeopleWhoHavePaid] == 0) {
        [mailBody appendFormat:@"%@\n", NSLocalizedString(@"EMAIL_NOBODY_HAS_PAID", @"The message that nobody has paid so far")];
    } else if ([[self tonightsBill] totalAmountOfPeopleWhoHavePaid] == 1) {
        [mailBody appendFormat:@"%@:\n", NSLocalizedString(@"EMAIL_ONE_PERSON_HAS_PAID", @"The person who has payed")];
    } else {
        [mailBody appendFormat:@"%@:\n", NSLocalizedString(@"EMAIL_MULTIPLE_PEOPLE_HAVE_PAID", @"The people who have paid are")];
    }
    NSArray *allPayments = [[[self tonightsBill] payments] sortedArrayUsingDescriptors:sda];
    for (MCPayment *p in allPayments) {
        NSString *whoHasPaid1 = NSLocalizedString(@"EMAIL_WHO_HAS_PAID_ONE", @"Part one of the sentence: Mark has paid $24 for beer.");
        NSString *whoHasPaid2 = NSLocalizedString(@"EMAIL_WHO_HAS_PAID_TWO", @"Part two of the sentence: Mark has paid $24 for beer.");
        [mailBody appendFormat:@"%@ %@ %@ %@ %@.\n", [[p payingPerson] getName], whoHasPaid1, [nf stringFromNumber:[p money]], whoHasPaid2, [p descriptionOfPayment]];
    }
    [mailBody appendFormat:@"\n"];
    NSString *average1 = NSLocalizedString(@"EMAIL_AVERAGE_SENTENCES_ONE", @"Part one of: To have everybody pay the average of $7.00, I suggest the following solution:");
    NSString *average2 = NSLocalizedString(@"EMAIL_AVERAGE_SENTENCES_TWO", @"Part two of: To have everybody pay the average of $7.00, I suggest the following solution:");
    [mailBody appendFormat:@"%@ %@%@:\n", average1, [nf stringFromNumber:[[self tonightsBill] amountPeopleShouldHavePaid]], average2];
    for (MCReturnPayment *rp in _solution) {
        [mailBody appendFormat:@"%@\n", [rp stringForMail]];
    }
    [mailBody appendFormat:@"\n"];
    [mailBody appendFormat:@"%@.", NSLocalizedString(@"EMAIL_FINAL SENTENCE", @"If you have any remarks please let me know.")];
    [_mailViewController setMessageBody:mailBody isHTML:NO];
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 2;
        case 1:
            return [_solution count];
        default:
            @throw [NSException exceptionWithName:@"TableView broken" reason:@"There are no more than 2 sections in this tableView." userInfo:nil];
            return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        MCSolutionOverViewTableViewCell_iPad *cell = [tableView dequeueReusableCellWithIdentifier:@"MCSolutionOverViewTableViewCell_iPad" forIndexPath:indexPath];
        
        if ([indexPath row] == 0) {
            NSString *totalSpentString = NSLocalizedString(@"TOTAL_SPENT", @"Total spent:");
            [[cell firstLabel] setText:totalSpentString];
            [[cell lastLabel] setText:[_tonightsBill totalSumOfMoneyOfThisSharedBillAsCurrencyString]];
        }
        if ([indexPath row] == 1) {
            NSString *eachPaysString = NSLocalizedString(@"EACH_PAYS", @"Each pays:");
            [[cell firstLabel] setText:eachPaysString];
            [[cell lastLabel] setText:[_tonightsBill amountPeopleShouldHavePaidAsCurrencyString]];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    
    if ([indexPath section] == 1) {
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
