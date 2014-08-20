//
//  MCSelectCurrencyTableViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 28/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCSelectCurrencyTableViewController.h"

#import "MCSelectCurrencyTableViewCell_iPhone.h"

#import "MCCurrency+addons.h"
#import "MCPayment+addons.h"
#import "MCExchangeRate+addons.h"
#import "MCWeAllPayStoreController.h"

#import "XRCurrency.h"
#import "XRCurrencyStoreController.h"

NSString * const cellIdentifier = @"MCSelectCurrencyTableViewCell_iPhone";

@interface MCSelectCurrencyTableViewController () <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSFetchedResultsController *dataController;
@property (nonatomic, strong) NSFetchedResultsController *searchDataController;
@property (nonatomic, strong) NSMutableArray *searchResults;

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
    NSArray *tempArray = [[_dataController fetchedObjects] filteredArrayUsingPredicate:predicate];
//    if (![scope isEqualToString:@"All"]) {
//        // Further filter the array with the scope
//        NSPredicate *scopePredicate = [NSPredicate predicateWithFormat:@"SELF.category contains[c] %@",scope];
//        tempArray = [tempArray filteredArrayUsingPredicate:scopePredicate];
//    }
    _searchResults = [NSMutableArray arrayWithArray:tempArray];
}

- (void)putIntThisPayment:(XRCurrency *)xrCurrency
{
#warning Incomplete method implementation.
    // If there is a currency on this payment update it with the new stuff.
    
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
    
    _dataController = [[XRCurrencyStoreController sharedStore] getFetchedResultsControllerForDelegate:nil];
    NSError *fetchError;
    if (![_dataController performFetch:&fetchError]) {
        NSLog(@"Error fetching XRCurrencies: %@", fetchError);
    }
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
    XRCurrency *thisCellsCurrency;
    if (tableView != [[self searchDisplayController] searchResultsTableView]) {
        thisCellsCurrency = [_dataController objectAtIndexPath:indexPath];
        [self putIntThisPayment:thisCellsCurrency];
//        [_thisPayment setNewCurrencyAndAutomaticallyUpdateExchangeRate:thisCellsCurrency];
    } else {
        thisCellsCurrency = [_searchResults objectAtIndex:[indexPath row]];
        [self putIntThisPayment:thisCellsCurrency];
//        [_thisPayment setNewCurrencyAndAutomaticallyUpdateExchangeRate:thisCellsCurrency];
    }
    [_thisPayment recalculateAveragePeopleOweAndStore];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView != [[self searchDisplayController] searchResultsTableView]) {
        return [[_dataController fetchedObjects] count];
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

    XRCurrency *thisCellsCurrency;
    if (tableView != [[self searchDisplayController] searchResultsTableView]) {
        thisCellsCurrency = [_dataController objectAtIndexPath:indexPath];
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
