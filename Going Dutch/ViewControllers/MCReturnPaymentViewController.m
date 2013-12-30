//
//  MCReturnPaymentViewController.m
//  Going Dutch
//
//  Created by Mark Cornelisse on 07-02-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCReturnPaymentViewController.h"
#import "MCSharedBillTableViewController.h"
#import "MCSharedBillPageViewController.h"

#import "MCSharedBill+addons.h"
#import "MCReturnPayment.h"
#import "MCPerson+addons.h"

#import "MCReturnPaymentTableViewCell.h"
#import "MCTwoLabelsTitleView.h"
#import "MCTableEmptyMessage.h"

@interface MCReturnPaymentViewController ()

@end

@implementation MCReturnPaymentViewController

@synthesize tonightsBill;
@synthesize sendMailObject;

#pragma mark - Actions

- (IBAction)sendAsEmailButtonPressed:(id)sender
{
    [sendMailObject shareBill:self];
}

- (IBAction)mainCancelButtonPressed:(id)sender
{
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - New in this Class

- (id)initWithBill:(MCSharedBill *)thisBill
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        if (!thisBill) {
            @throw [NSException exceptionWithName:@"InitWithNil" reason:@"thisBill is not allowed to point to nil." userInfo:nil];
        }
        tonightsBill = thisBill;

    }
    return self;
}

- (void)setEmptyMessage
{
    if (![paymentsAfterwards count] == 0) {
        [UIView animateWithDuration:1.0 animations:^{
            [[emptyMessage bigMessage] setAlpha:0.0];
            [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        } completion:nil];
    } else {
        [UIView animateWithDuration:1.0 animations:^{
            [[emptyMessage bigMessage] setAlpha:1.0];
            [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        } completion:nil];
    }
}

#pragma mark - Inherited from super.

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!twoLabelTitleView) {
        twoLabelTitleView = [[[NSBundle mainBundle] loadNibNamed:@"MCTwoLabelsTitleView" owner:self options:nil] objectAtIndex:0];
        [[self navigationItem] setTitleView:twoLabelTitleView];
    }
    NSNumber *averagePay = [tonightsBill amountPeopleShouldHavePaid];
    NSNumber *totalSpent = [tonightsBill totalSumOfMoneyOfThisSharedBill];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *eachPays = NSLocalizedString(@"EACH_PAYS", @"Each pays: $ string inside the header of the solution screen");
    [[twoLabelTitleView mainLabel] setText:[NSString stringWithFormat:@"%@ %@", eachPays, [nf stringFromNumber:averagePay]]];
    NSString *totalSpentString = NSLocalizedString(@"TOTAL_SPENT", @"Total spent: $ string inside the header of the solution screen.");
    [[twoLabelTitleView subLabel] setText:[NSString stringWithFormat:@"%@ %@", totalSpentString, [nf stringFromNumber:totalSpent]]];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [[twoLabelTitleView mainLabel] setTextColor:[UIColor whiteColor]];
        [[twoLabelTitleView subLabel] setTextColor:[UIColor whiteColor]];
    }
    
    [self setEmptyMessage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setWillShowButtons:NO];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [MCTools setAdBannerIfNotPaid:NO forViewController:self];
    } else {
        [MCTools setAdBannerIfNotPaid:YES forViewController:self];
    }
    
    paymentsAfterwards = [[NSMutableArray alloc] init];
    for (MCReturnPayment *rp in [tonightsBill solveWhoHasToPayWhoFromThisBill]) {
        if ([rp receiver]) {
            [paymentsAfterwards addObject:rp];
        }
    }
    
    emptyMessage = [[[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage" owner:self options:nil] objectAtIndex:0];
    [[self tableView] setBackgroundView:emptyMessage];
    [[emptyMessage bigMessage] setText:NSLocalizedString(@"RETURNPAYMENTSVIEW_NOPAYMENTS", @"Please add payments and/or people if you want a solution on who owes who.")];
    [[self tableView] reloadData];
    
    UINib *nib = [UINib nibWithNibName:@"MCReturnPaymentTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"MCReturnPaymentTableViewCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"Cancel button pressed");
            break;
        case 1:
            [[self sendMailObject] openMailView:self];
            break;
        case 2:
            //[[self sendMailObject ] editBillData:self];
            NSLog(@"If you see this there was a button that shouldn't be there.");
            break;
        default:
            break;
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultCancelled) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    } else if (result == MFMailComposeResultSent) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    } else if (result == MFMailComposeResultSaved) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSLog(@"Sending email went wrong: %@", [error localizedDescription]);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [paymentsAfterwards count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCReturnPayment *thisCellsReturnPayment = [paymentsAfterwards objectAtIndex:[indexPath row]];
    MCReturnPaymentTableViewCell *returnPaymentCell = [tableView dequeueReusableCellWithIdentifier:@"MCReturnPaymentTableViewCell"];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSNumber *moneyToConvert = [thisCellsReturnPayment money];
    [[returnPaymentCell moneyLabel] setText:[nf stringFromNumber:moneyToConvert]];
    
    NSString *owesString = NSLocalizedString(@"OWES", @"As in Mark owes Arjen, but then just the word owes.");
    NSString *whoOwesWho = [[NSString alloc] initWithFormat:@"%@ %@ %@:", [[thisCellsReturnPayment payer] getName], owesString, [[thisCellsReturnPayment receiver] getName]];
    [[returnPaymentCell whoOwesWho] setText:whoOwesWho];
    [returnPaymentCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return returnPaymentCell;
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
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
