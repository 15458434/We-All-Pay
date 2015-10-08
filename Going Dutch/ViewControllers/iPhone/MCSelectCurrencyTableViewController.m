//
//  MCSelectCurrencyTableViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 28/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCSelectCurrencyTableViewController.h"

#import "MCCurrency+addons.h"
#import "MCPayment+addons.h"
#import "MCExchangeRate+addons.h"
#import "MCWeAllPayStoreController.h"

#import "We_all_pay-Swift.h"

NSString * const cellIdentifier = @"MCSelectCurrencyTableViewCell_iPhone";

@interface MCSelectCurrencyTableViewController () <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *currencies;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSFetchedResultsController *searchDataController;
@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, strong) UIAlertView *exchangeRateFetchErrorAlert;

@end

@implementation MCSelectCurrencyTableViewController

#pragma mark - Actions

- (IBAction)mainCancelPressed:(id)sender
{
    // Don't select anything just dismiss the currency view controller
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private in this class

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	// Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
	[_searchResults removeAllObjects];
	// Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@ || code contains[c] %@",searchText, searchText];
    NSArray *tempArray = [_currencies filteredArrayUsingPredicate:predicate];
//    if (![scope isEqualToString:@"All"]) {
//        // Further filter the array with the scope
//        NSPredicate *scopePredicate = [NSPredicate predicateWithFormat:@"SELF.category contains[c] %@",scope];
//        tempArray = [tempArray filteredArrayUsingPredicate:scopePredicate];
//    }
    _searchResults = [NSMutableArray arrayWithArray:tempArray];
}

- (void)addNewCurrencyToThisPayment:(NSString *)code withCompletionHandler:(void (^)(NSError *error))completion {
    NSManagedObjectContext *mainThreadContext = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
    MCCurrency *newCurrency = [MCCurrency currencyFrom:code fromContext:mainThreadContext];
    MCCurrency *oldCurrency = _thisPayment.currency;
    _thisPayment.currency = newCurrency;
    if (oldCurrency.sharedBill.count == 0 && oldCurrency.payment.count == 0) {
        [mainThreadContext deleteObject:oldCurrency];
    }
    [_thisPayment setNewCurrencyAndAutomaticallyUpdateExchangeRate:newCurrency withCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Error fetching ExchangeRate: %@", error);
            completion(error);
            return;
        }
        completion(nil);
    }];
}

- (void)setObjects:(NSArray *)objects {
    SEL selector = @selector(name);
    NSInteger sectionTitlesCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
    
    NSMutableArray *mutableSections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    for (NSUInteger idx = 0; idx < sectionTitlesCount; idx++) {
        [mutableSections addObject:[NSMutableArray array]];
    }
    
    for (id object in objects) {
        NSInteger sectionNumber = [[UILocalizedIndexedCollation currentCollation] sectionForObject:object collationStringSelector:selector];
        [[mutableSections objectAtIndex:sectionNumber] addObject:object];
    }
    
    for (NSUInteger idx = 0; idx < sectionTitlesCount; idx++) {
        NSArray *objectsForSection = [mutableSections objectAtIndex:idx];
        [mutableSections replaceObjectAtIndex:idx withObject:[[UILocalizedIndexedCollation currentCollation] sortedArrayFromArray:objectsForSection collationStringSelector:selector]];
    }
    
    self.sections = mutableSections;
    
    [self.tableView reloadData];
}

#pragma mark - Inherited From Super

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
    
    _currencies = [[[[MCWeAllPayStoreController defaultStore] fetcher] currencyController] currencies];
    [self setObjects:_currencies];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search Display Controller

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *myPresenter = self.presentingViewController;
    
    NSDictionary *thisCellsCurrency;
    if (tableView != [[self searchDisplayController] searchResultsTableView]) {
        thisCellsCurrency = _sections[[indexPath section]][[indexPath row]];
        [self addNewCurrencyToThisPayment:thisCellsCurrency[@"code"] withCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"Error changing currency: %@", error);
                
                NSString *title = NSLocalizedString(@"Unable to fetch exchange rates", @"Title message of an alert that pops up when fetching exchange rates is impossible");
                NSString *message = NSLocalizedString(@"Fetching exchange rates is not possible at this moment. Check your internet connection and/or hit solve to fetch all missing exchange rates at a later time", @"Message explaining what the user can do to refetch exchange rates");
                NSString *dismissTitle = NSLocalizedString(@"Dismiss", @"Title of a button that dismisses an alert.");
                
                if ([UIAlertController class]) {
                    // iOS 8 and up.
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:dismissTitle style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:dismissAction];
                    [myPresenter presentViewController:alertController animated:YES completion:nil];
                }
            }
        }];
    } else {
        thisCellsCurrency = [_searchResults objectAtIndex:[indexPath row]];
        [self addNewCurrencyToThisPayment:thisCellsCurrency[@"code"] withCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"Error changing currency: %@", error);
                
                NSString *title = NSLocalizedString(@"Unable to fetch exchange rates", @"Title message of an alert that pops up when fetching exchange rates is impossible");
                NSString *message = NSLocalizedString(@"Fetching exchange rates is not possible at this moment. Check your internet connection and/or hit solve to fetch all missing exchange rates at a later time", @"Message explaining what the user can do to refetch exchange rates");
                if ([UIAlertController class]) {
                    // iOS 8 and up.
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
                    NSString *dismissTitle = NSLocalizedString(@"Dismiss", @"Title of a button that dismisses an alart.");
                    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:dismissTitle style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:dismissAction];
                    [myPresenter presentViewController:alertController animated:YES completion:nil];
                }

            }
        }];
    }
    [_thisPayment recalculateAveragePeopleOweAndStore];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView != [[self searchDisplayController] searchResultsTableView]) {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    } else {
        return @"";
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (tableView != [[self searchDisplayController] searchResultsTableView]) {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView != [[self searchDisplayController] searchResultsTableView]) {
//        return [[_dataController fetchedObjects] count];
        return [_sections[section] count];
    } else {
        return [_searchResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCSelectCurrencyTableViewCell_iPhone *cell = (MCSelectCurrencyTableViewCell_iPhone *)[[self tableView] dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MCSelectCurrencyTableViewCell_iPhone alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    Currency *thisCellsCurrency;
    if (tableView != [[self searchDisplayController] searchResultsTableView]) {
        thisCellsCurrency = _sections[[indexPath section]][[indexPath row]];
    } else {
        thisCellsCurrency = [_searchResults objectAtIndex:[indexPath row]];
    }
    cell.currencyNameLabel.text = [thisCellsCurrency name];
    cell.currencySymbolLabel.text = [thisCellsCurrency symbol];
    
    if ([[[_thisPayment currency] code] isEqualToString:[thisCellsCurrency code]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
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
