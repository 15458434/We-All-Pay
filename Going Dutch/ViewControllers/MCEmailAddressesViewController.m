//
//  MCEmailAddressesViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 17-10-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCEmailAddressesViewController.h"
#import "MCWeAllPayStoreController.h"
#import "MCEmailAddress+addons.h"
#import "MCPerson.h"

@interface MCEmailAddressesViewController ()

@end

@implementation MCEmailAddressesViewController

@synthesize thisPerson;

#pragma mark - New in this class

- (id)initWithPerson:(MCPerson *)person
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        thisPerson = person;
    }
    return self;
}

- (void)prepareDataController
{
    if (!dataController) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCEmailAddress"];
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"MCEmailAddress" ascending:YES];
        NSArray *sda = [NSArray arrayWithObject:sd];
        [request setSortDescriptors:sda];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owner = %@", thisPerson];
        [request setPredicate:predicate];
        NSManagedObjectContext *context = [[[MCWeAllPayStoreController defaultStore] weAllPayStoreDocument] managedObjectContext];
        dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                             managedObjectContext:context
                                                               sectionNameKeyPath:nil
                                                                        cacheName:[NSString stringWithFormat:@"All emailAddresses of %@", [thisPerson uniquePersonId]]];
    }
}

#pragma mark - Inherited From Super

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self prepareDataController];
    
    // Load and register Nib to the tableView for use.
    UINib *nib = [UINib nibWithNibName:@"MCEmailAddressTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"emailAddressCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self performFetch];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"emailAddressCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - TableViewDataSource

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

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

@end
