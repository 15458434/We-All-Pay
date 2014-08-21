//
//  MCSelectCurrencyTableViewController_iPad.m
//  We all pay
//
//  Created by Mark Cornelisse on 25/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCSelectCurrencyTableViewController_iPad.h"
#import "MCSelectCurrencyTableViewCell_iPad.h"

#import "MCCurrency+addons.h"
#import "MCPayment+addons.h"

#import "MCWeAllPayStoreController.h"
#import "XRCurrencyStoreController.h"
#import "XRCurrency.h"

NSString * const currencyCellIdentifier_iPad = @"MCSelectCurrencyTableViewCell_iPad";

@interface MCSelectCurrencyTableViewController_iPad () <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSFetchedResultsController *dataController;
@property (nonatomic, strong) NSMutableArray *searchResults;

@end

@implementation MCSelectCurrencyTableViewController_iPad

#pragma mark - Private in this class

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	[_searchResults removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@ || code contains[c] %@",searchText, searchText];
    NSArray *tempArray = [[_dataController fetchedObjects] filteredArrayUsingPredicate:predicate];
    _searchResults = [NSMutableArray arrayWithArray:tempArray];
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
//    _dataController = [[MCWeAllPayStoreController defaultStore] availableCurrencyControllerForDelegate:self];
    _dataController = [[XRCurrencyStoreController sharedStore] getFetchedResultsControllerForDelegate:self];
    NSError *fetchError;
    if (![_dataController performFetch:&fetchError]) {
        NSLog(@"Error fetching currencies: %@", fetchError);
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
    XRCurrency *selectedCurrency;
    NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
    if (tableView != [[self searchDisplayController] searchResultsTableView]) {
        selectedCurrency = [_dataController objectAtIndexPath:indexPath];
        [_thisPayment setNewCurrencyAndAutomaticallyUpdateExchangeRate:[MCCurrency getCurrencyFrom:selectedCurrency FromContext:context]];
    } else {
        selectedCurrency = [_searchResults objectAtIndex:[indexPath row]];
        [_thisPayment setNewCurrencyAndAutomaticallyUpdateExchangeRate:[MCCurrency getCurrencyFrom:selectedCurrency FromContext:context]];
    }
    [_thisPayment recalculateAveragePeopleOweAndStore];
    self.dismissMe();
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
    MCSelectCurrencyTableViewCell_iPad *cell = (MCSelectCurrencyTableViewCell_iPad *)[[self tableView] dequeueReusableCellWithIdentifier:currencyCellIdentifier_iPad];
    if (cell == nil) {
        cell = [[MCSelectCurrencyTableViewCell_iPad alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:currencyCellIdentifier_iPad];
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
