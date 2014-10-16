//
//  MCSelectCategoryTableViewController_iPad.m
//  We all pay
//
//  Created by Mark Cornelisse on 16/10/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCSelectCategoryTableViewController_iPad.h"

#include "MCPayment+addons.h"

#import "MCCategoryPictureStoreController.h"
#import "MCCategoryPictureObject.h"

#import "MCSelectCategoryTableViewCell_iPad.h"

@interface MCSelectCategoryTableViewController_iPad ()

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *categorySections;
@property (nonatomic, strong) NSMutableArray *filteredCategories;

@end

@implementation MCSelectCategoryTableViewController_iPad

#pragma mark - Private in this class

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [_filteredCategories removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryDescription contains[c] %@",searchText];
    NSArray *tempArray = [_categories filteredArrayUsingPredicate:predicate];
#if DEBUG
    NSLog(@"tempArray contains: %lu results", (unsigned long)tempArray.count);
#endif
    //    if (![scope isEqualToString:@"All"]) {
    //        // Further filter the array with the scope
    //        NSPredicate *scopePredicate = [NSPredicate predicateWithFormat:@"SELF.category contains[c] %@",scope];
    //        tempArray = [tempArray filteredArrayUsingPredicate:scopePredicate];
    //    }
    _filteredCategories = [NSMutableArray arrayWithArray:tempArray];
}


- (void)createSections:(NSArray *)objects
{
    SEL selector = @selector(categoryDescription);
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
    
    _categorySections = mutableSections;
    
    [self.tableView reloadData];
}

#pragma mark - Inherited from super

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _categories = [[MCCategoryPictureStoreController sharedController] pictureObjects];
    [self createSections:_categories];
    _filteredCategories = [NSMutableArray arrayWithCapacity:_categories.count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search bar delegate

#pragma mark - Search display delegate

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [tableView registerClass:[MCSelectCategoryTableViewCell_iPad class] forCellReuseIdentifier:@"selectCategoryCell"];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return _categorySections.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return _filteredCategories.count;
    } else {
        return [[_categorySections objectAtIndex:section] count];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCCategoryPictureObject *categoryObject;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        categoryObject = _filteredCategories[indexPath.row];
    } else {
        NSArray *sectionArray = _categorySections[indexPath.section];
        categoryObject = sectionArray[indexPath.row];
    }
    _thisPayment.categoryId = @([categoryObject categoryId]);
    self.dismissMe();
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    }
    return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCSelectCategoryTableViewCell_iPad *cell = (MCSelectCategoryTableViewCell_iPad *)[tableView dequeueReusableCellWithIdentifier:@"selectCategoryCell" forIndexPath:indexPath];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        MCCategoryPictureObject *category = [_filteredCategories objectAtIndex:[indexPath row]];
        cell.textLabel.text = category.categoryDescription;
        cell.imageView.image = category.smallPicture;
//        cell.categoryNameLabel.text = category.categoryDescription;
//        cell.categoryImageView.image = category.smallPicture;
    } else {
        NSArray *arrayOfSection = [_categorySections objectAtIndex:[indexPath section]];
        MCCategoryPictureObject *category = [arrayOfSection objectAtIndex:[indexPath row]];
        cell.categoryNameLabel.text = category.categoryDescription;
        cell.categoryImageView.image = category.smallPicture;
    }
    
    return cell;

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
