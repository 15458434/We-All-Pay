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
#import "MCWeAllPayStoreController.h"

#import "MCReturnPaymentTableViewCell.h"
#import "MCSolutionOverViewTableViewCell_iPhone.h"
#import "MCWhoOwesWhoTableViewCell_iPhone.h"
#import "MCWhoPaidHowMuchTableViewCell_iPhone.h"
#import "MCTwoLabelsTitleView.h"
#import "MCTableEmptyMessage.h"

typedef NS_ENUM(BOOL, MCXRatesMissing) {
    xRatesPresent,
    xRatesMissing
};

@interface MCReturnPaymentViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *peoplePresent;
@property (nonatomic, strong) NSMutableArray *paymentsAfterwards;

@property (nonatomic) MCXRatesMissing areXRatesMissing;
@property (nonatomic, strong) UIAlertView *noXRatesAlert;
@property (nonatomic, strong) UIAlertController *rateMeAlert;

@property (nonatomic, strong) MCTableEmptyMessage *emptyMessage;

@end

@implementation MCReturnPaymentViewController

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

#pragma mark - Private in this class

- (void)showRateMe
{
    _rateMeAlert = [UIAlertController alertControllerWithTitle:@"Please Rate Me" message:@"Do you like We all pay? If so please take some time to leave a rating in the App Store" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *rateMe = [UIAlertAction actionWithTitle:@"rate me" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Rate me");
    }];
    UIAlertAction *later = [UIAlertAction actionWithTitle:@"later" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Later");
    }];
    UIAlertAction *never = [UIAlertAction actionWithTitle:@"never" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Never!!");
    }];
    [_rateMeAlert addAction:never];
    [_rateMeAlert addAction:later];
    [_rateMeAlert addAction:rateMe];
    [self presentViewController:_rateMeAlert animated:YES completion:nil];
}

- (NSArray *)giveSolution
{
    __weak typeof(self) weakSelf = self;
    NSArray *directResults = [_tonightsBill solveWhoHasToPayWhoFromThisBillWithCompletionBlock:^(NSArray *results) {
        // Update tableView.
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.areXRatesMissing = xRatesPresent;

            // What the hell was I thinking during writing this???
            strongSelf.paymentsAfterwards = [[NSMutableArray alloc] init];
            for (MCReturnPayment *rp in results) {
                if ([rp receiver]) {
                    [[strongSelf paymentsAfterwards] addObject:rp];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Stop animating.");
                [[[strongSelf emptyMessage] activityIndicator] stopAnimating];
                [strongSelf setEmptyMessage];
                [[strongSelf tableView] insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationTop];
            });
        }
    }];
    if (!directResults) {
        NSLog(@"Start animating");
        [_emptyMessage.activityIndicator startAnimating];
    }
    return directResults;
}

#pragma mark - New in this Class

- (id)initWithBill:(MCSharedBill *)thisBill
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        if (!thisBill) {
            @throw [NSException exceptionWithName:@"InitWithNil" reason:@"thisBill is not allowed to point to nil." userInfo:nil];
        }
        _tonightsBill = thisBill;

    }
    return self;
}

- (void)setEmptyMessage
{
    if (![_paymentsAfterwards count] == 0 || _emptyMessage.activityIndicator.isAnimating) {
        [UIView animateWithDuration:1.0 animations:^{
            [[_emptyMessage bigMessage] setAlpha:0.0];
            [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        } completion:nil];
    } else {
        [UIView animateWithDuration:1.0 animations:^{
            [[_emptyMessage bigMessage] setAlpha:1.0];
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
    
    if ([_tonightsBill areAllExchangeRatesValid]) {
        _areXRatesMissing = xRatesPresent;
    } else {
        _areXRatesMissing = xRatesMissing;
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    _peoplePresent = [[_tonightsBill peoplePresent] sortedArrayUsingDescriptors:@[sortDescriptor]];

    _emptyMessage = [[NSBundle mainBundle] loadNibNamed:@"MCTableEmptyMessage" owner:self options:nil][0];
    [[self tableView] setBackgroundView:_emptyMessage];
    [[_emptyMessage bigMessage] setText:NSLocalizedString(@"RETURNPAYMENTSVIEW_NOPAYMENTS", @"Please add payments and/or people if you want a solution on who owes who.")];
    [[_emptyMessage bigMessage] setAlpha:0.0];
    
    _paymentsAfterwards = [[NSMutableArray alloc] init];
    for (MCReturnPayment *rp in [self giveSolution]) {
        if ([rp receiver]) {
            [_paymentsAfterwards addObject:rp];
        }
    }

    [[self tableView] reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    if (_areXRatesMissing == xRatesMissing) {
//        NSString *title = NSLocalizedString(@"UNABLE_TO_SOLVE", @"Unable to solve");
//        NSString *message = NSLocalizedString(@"UNABLE_TO_SOLVE_MESSAGE", @"Exchange rates missing. Would you like to fetch them now?");
//        NSString *cancelButton = NSLocalizedString(@"NO", @"No");
//        NSString *firstButton = NSLocalizedString(@"YES", @"Yes");
//        _noXRatesAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButton otherButtonTitles:firstButton, nil];
//        [_noXRatesAlert show];
//    }
    
    [self setEmptyMessage];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:@"MCSolutionScreen_iPhone"];
//    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _noXRatesAlert) {
        switch (buttonIndex) {
            case 0:
                NSLog(@"No xRates Fetch.");
                break;
            case 1:
                NSLog(@"Yes xRates Fetch.");
                [self giveSolution];
                break;
            default:
                break;
        }
    } else {
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

}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultCancelled) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    } else if (result == MFMailComposeResultSent) {
        // TODO: add rate me here.
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:^{
            [_tonightsBill setHasTheMailBeenSent:@YES];
            [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
        }];
//        if (1) {
//            [self showRateMe];
//        } else {
//            
//        }
    } else if (result == MFMailComposeResultSaved) {
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSLog(@"Sending email went wrong: %@", [error localizedDescription]);
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *sectionTitleHeader = (UITableViewHeaderFooterView *)view;
    [view setTintColor:[MCColors getbackgroundColor]];
    [[sectionTitleHeader textLabel] setTextColor:[MCColors getEmptyMessageTextColor]];
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
    if ([_paymentsAfterwards count] > 0) {
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
        NSLog(@"Amount of sections is 0.");
        return 0;
    } else {
        NSLog(@"Amount of sections is 3.");
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [_paymentsAfterwards count];
        case 1:
            if ([_paymentsAfterwards count] == 0) {
                return 0;
            } else {
                return [_peoplePresent count];
            }
        case 2:
            if ([_paymentsAfterwards count] == 0) {
                return 0;
            } else {
                return [[_tonightsBill peoplePresent] count] + 1;
            }
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        MCReturnPayment *thisCellsReturnPayment = _paymentsAfterwards[[indexPath row]];
        MCWhoOwesWhoTableViewCell_iPhone *returnPaymentCell = [tableView dequeueReusableCellWithIdentifier:@"MCWhoOwesWhoTableViewCell_iPhone"];
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
        NSNumber *moneyToConvert = [thisCellsReturnPayment money];
        [[returnPaymentCell moneyLabel] setText:[nf stringFromNumber:moneyToConvert]];
        
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
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        [nf setLocale:[NSLocale currentLocale]];
        [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
        [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
        [[cell moneyLabel] setText:[nf stringFromNumber:sumSpentByPerson]];
        return cell;
    }
    
    if ([indexPath section] == 2) {
        if ([indexPath row] < [_peoplePresent count]) {
            MCWhoPaidHowMuchTableViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:@"MCWhoPaidHowMuchTableViewCell_iPhone"];
            
            MCPerson *person = [_peoplePresent objectAtIndex:[indexPath row]];
            [[cell whoPaidHowMuchLabel] setText:[person getFullName]];
            NSNumber *sumSpentByPerson = [_tonightsBill totalSumPaidBy:person];
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setLocale:[NSLocale currentLocale]];
            [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
            [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
            [[cell moneyLabel] setText:[nf stringFromNumber:sumSpentByPerson]];
            return cell;
        } else {
            MCSolutionOverViewTableViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:@"MCSolutionOverViewTableViewCell_iPhone"];
            NSString *totalSpentString = NSLocalizedString(@"TOTAL_SPENT", @"Total spent:");
            [[cell totalLabel] setText:totalSpentString];
            [[cell moneyLabel] setText:[_tonightsBill totalSumOfMoneyOfThisSharedBillAsCurrencyString]];
            return cell;
        }
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
