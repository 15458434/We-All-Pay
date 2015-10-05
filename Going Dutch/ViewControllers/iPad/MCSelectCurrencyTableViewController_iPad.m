//
//  MCSelectCurrencyTableViewController_iPad.m
//  We all pay
//
//  Created by Mark Cornelisse on 25/07/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCSelectCurrencyTableViewController_iPad.h"

#import "MCCurrency+addons.h"
#import "MCPayment+addons.h"
#import "MCSharedBill+addons.h"

#import "MCWeAllPayStoreController.h"
#import "We_all_pay-Swift.h"

NSString * const currencyCellIdentifier_iPad = @"MCSelectCurrencyTableViewCell_iPad";

@interface MCSelectCurrencyTableViewController_iPad () <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSArray *currencies;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableArray *searchResults;

@end

@implementation MCSelectCurrencyTableViewController_iPad

#pragma mark - Private in this class

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

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	[_searchResults removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@ || code contains[c] %@",searchText, searchText];
    NSArray *tempArray = [_currencies filteredArrayUsingPredicate:predicate];
    _searchResults = [NSMutableArray arrayWithArray:tempArray];
}

#pragma mark - Inherited from super

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currencies = [[[[MCWeAllPayStoreController defaultStore] fetcher] currencyController] currencies];
    [self setObjects:_currencies];
}

- (void)viewWillDisappear:(BOOL)animated
{
#if DEBUG
    NSLog(@"%@ viewWillDisappear", self);
#endif
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
#if DEBUG
    NSLog(@"%@, viewDidDisappear", self);
#endif
    [super viewDidDisappear:animated];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#if DEBUG
    NSLog(@"%@ didSelectRowAtIndexPath", self);
#endif
    NSDictionary *selectedCurrency;
    NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
    if (tableView != [[self searchDisplayController] searchResultsTableView]) {
        selectedCurrency = _sections[[indexPath section]][[indexPath row]];
        [_thisPayment setNewCurrencyAndAutomaticallyUpdateExchangeRate:[MCCurrency currencyFrom:selectedCurrency[@"code"] fromContext:context] withCompletionHandler:^(NSError *error) {
            NSLog(@"Error fetching exchangeRate: %@", error);
        }];
    } else {
        selectedCurrency = [_searchResults objectAtIndex:[indexPath row]];
        [_thisPayment setNewCurrencyAndAutomaticallyUpdateExchangeRate:[MCCurrency currencyFrom:selectedCurrency[@"code"] fromContext:context] withCompletionHandler:^(NSError *error) {
            NSLog(@"Error fetching exchangeRate: %@", error);
        }];
    }
    [_thisPayment recalculateAveragePeopleOweAndStore];
    self.dismissMe();
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

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
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
        return [_sections[section] count];
    } else {
        return [_searchResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectCurrencyTableViewCell_iPad *cell = (SelectCurrencyTableViewCell_iPad *)[[self tableView] dequeueReusableCellWithIdentifier:currencyCellIdentifier_iPad];
    if (cell == nil) {
        cell = [[SelectCurrencyTableViewCell_iPad alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:currencyCellIdentifier_iPad];
    }
    
    NSDictionary *thisCellsCurrency;
    if (tableView != [[self searchDisplayController] searchResultsTableView]) {
        thisCellsCurrency = _sections[[indexPath section]][[indexPath row]];
    } else {
        thisCellsCurrency = [_searchResults objectAtIndex:[indexPath row]];
    }
    cell.currencyNameLabel.text = thisCellsCurrency[@"name"];
    NSString *currencySymbol = [[[[MCWeAllPayStoreController defaultStore] fetcher] currencyController] currencySymbol:thisCellsCurrency[@"code"]];
    cell.currencySymbolLabel.text = currencySymbol;
    
    if ([[[_thisPayment currency] code] isEqualToString:currencySymbol]) {
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
