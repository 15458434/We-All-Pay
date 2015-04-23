//
//  MCiScreenTableViewController_iPad.m
//  We all pay
//
//  Created by Mark Cornelisse on 17-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCiScreenTableViewController_iPad.h"

#import "MCOneLabelTableViewCell_iPad.h"
#import "MCTwoLabelTableViewCell_iPad.h"

#import "MCStoreInterface.h"
#import "SKProduct+MCStoreInterface.h"

#import "MCWeAllPayStoreController.h"

@interface MCiScreenTableViewController_iPad ()

@end

@implementation MCiScreenTableViewController_iPad

#pragma mark - Actions

- (IBAction)createCirclePictures:(id)sender {
    [[MCWeAllPayStoreController defaultStore] createCircularPeopleImages];
}

- (IBAction)tweetUsPressed:(id)sender
{
    SLComposeViewController *twitterComposer= [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [twitterComposer setInitialText:@".@MarkCornelisse Thank you for creating We all pay. #ios #app"];
    [twitterComposer addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/we-all-pay/id642135963?ls=1&mt=8"]];
    [self presentViewController:twitterComposer animated:YES completion:nil];
}

#pragma mark - Private in this class

- (NSUInteger)getAmountOfRowsInSection0
{
    if ([MCStoreInterface canMakePayments] && ![[MCStoreInterface defaultStoreInterface] isProProductPurchased]) {
        return 2;
    } else {
        return 0;
    }
}

- (void)applyProVersion:(NSNotification *)notification
{
    numberOfRowsInSection0 = [self getAmountOfRowsInSection0];
    [[self tableView] deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0], [NSIndexPath indexPathForRow:1 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    UIAlertView *thankYouForPurchasingPopup;
    NSString *dismiss = NSLocalizedString(@"OK", @"Ok");
    if ([[[notification userInfo] valueForKeyPath:@"Kind of purchase"] isEqualToString:@"new buy"]) {
        NSString *thankYouTitleString = NSLocalizedString(@"THANK_YOU_FOR_PURCHASING", @"Thank you for purchasing.");
        NSString *noAdsString = NSLocalizedString(@"I_WILL_SHOW_NO_ADS", @"We all pay is now free of any ads.");
        thankYouForPurchasingPopup = [[UIAlertView alloc] initWithTitle:thankYouTitleString message:noAdsString delegate:self cancelButtonTitle:dismiss otherButtonTitles:nil];
    } else if ([[[notification userInfo] valueForKeyPath:@"Kind of purchase"] isEqualToString:@"restore purchase"]) {
        NSString *restoredString = NSLocalizedString(@"PURCHASE_RESTORED", @"Ad free version restored.");
        thankYouForPurchasingPopup = [[UIAlertView alloc] initWithTitle:restoredString message:nil delegate:self cancelButtonTitle:dismiss otherButtonTitles:nil];
    }
    [thankYouForPurchasingPopup show];
}

- (void)postProductPrice:(NSNotification *)notification
{
    MCTwoLabelTableViewCell_iPad *cell = (MCTwoLabelTableViewCell_iPad *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [[cell rightLabel] setText:[[[MCStoreInterface defaultStoreInterface] proProduct] priceString]];
}

- (void)restorePreviousPurchasesFailed:(NSNotification *)notification
{
    if ([[[notification userInfo] valueForKey:@"status"] isEqualToString:@"Not restored"]) {
        UIAlertView *restorePurchaseFailed;
        NSString *restorePurchaseFailedString = NSLocalizedString(@"RESTORE_PURCHASE_FAILED", @"Nothing to restore");
        restorePurchaseFailed = [[UIAlertView alloc] initWithTitle:restorePurchaseFailedString message:nil delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [restorePurchaseFailed show];
    }
}

#pragma mark - Inherited froms super.

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
    
    //[[self tableView] setBackgroundColor:[MCColors getbackgroundColor]];
    
    numberOfRowsInSection0 = [self getAmountOfRowsInSection0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyProVersion:) name:applyProVersionNotification object:[MCStoreInterface defaultStoreInterface]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postProductPrice:) name:@"Product price" object:[MCStoreInterface defaultStoreInterface]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restorePreviousPurchasesFailed:) name:@"Restore previous purchases" object:[MCStoreInterface defaultStoreInterface]];
    
    // Set the current screen in Google Analytics
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:@"MCiScreenViewController_iPhone"];
//    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"AlertView is dismissed.");
}

#pragma mark - MFMailComposeDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            // Cancelled by user.
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case MFMailComposeResultFailed:
            // Failed somehow.
            break;
        case MFMailComposeResultSaved:
            // Succesfully saved.
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case MFMailComposeResultSent:
            // Yay succesfully sent.
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        default:
            NSLog(@"This should not be possible.");
            break;
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        // If something in section one is pressed.
        if ([indexPath row] == 0) {
//            // Not implemented yet.
//        }
//        if ([indexPath row] == 1) {
            [[MCStoreInterface defaultStoreInterface] buyProProductSendFrom:self];
        }
        if ([indexPath row] == 1) {
            [[MCStoreInterface defaultStoreInterface] restorePreviousPurchases];
        }

    } else if ([indexPath section] == 1) {
        if ([indexPath row] == 0) {
            MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
            [mailComposer setToRecipients:@[ @"support@markcornelisse.nl" ]];
            NSString *subjectString = [NSString stringWithFormat:@"Feedback on We all pay %@ for %@", [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], [[UIDevice currentDevice] model]];
            [mailComposer setSubject:subjectString];
            [mailComposer setMailComposeDelegate:self];
            [self presentViewController:mailComposer animated:YES completion:^{
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                [mailComposer setNeedsStatusBarAppearanceUpdate];
            }];
        }
    }
    UITableViewCell *thisCell = [[self tableView] cellForRowAtIndexPath:indexPath];
    [thisCell setSelected:NO];
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
            return numberOfRowsInSection0;
            break;
        case 1:
            return 1;
            break;
        default:
            return 0;
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        if ([indexPath row] == 0) {
//            MCOneLabelTableViewCell_iPad *cell = [tableView dequeueReusableCellWithIdentifier:@"MCOneLabelTableViewCell_iPad" forIndexPath:indexPath];
//            NSString *whatIsProString = NSLocalizedString(@"WHAT_IS_PRO", @"What is the Pro Version");
//            [[cell oneTextLabel] setText:whatIsProString];
//            return cell;
//        } else if ([indexPath row] == 1) {
            MCTwoLabelTableViewCell_iPad *cell = [tableView dequeueReusableCellWithIdentifier:@"MCTwoLabelTableViewCell_iPad" forIndexPath:indexPath];
            NSString *buyProString = NSLocalizedString(@"BUY_PRO", @"Buy Pro Version");
            [[cell leftLabel] setText:buyProString];
            [[cell rightLabel] setText:[[[MCStoreInterface defaultStoreInterface] proProduct] priceString]];
            return cell;
        } else if ([indexPath row] == 1) {
            MCOneLabelTableViewCell_iPad *cell = [tableView dequeueReusableCellWithIdentifier:@"MCOneLabelTableViewCell_iPad" forIndexPath:indexPath];
            NSString *restorePurchaseString = NSLocalizedString(@"RESTORE_PREVIOUS_PURCHASES", @"Restore previous purchases");
            [[cell oneTextLabel] setText:restorePurchaseString];
            return cell;
        }
    } else if ([indexPath section] == 1) {
        if ([indexPath row] == 0) {
            MCOneLabelTableViewCell_iPad *cell = [tableView dequeueReusableCellWithIdentifier:@"MCOneLabelTableViewCell_iPad" forIndexPath:indexPath];
            NSString *feedbackString = NSLocalizedString(@"GIVE_FEEDBACK", @"Give feedback");
            [[cell oneTextLabel] setText:feedbackString];
            return cell;
        }
    } else {
        NSLog(@"This should not be happening.");
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
