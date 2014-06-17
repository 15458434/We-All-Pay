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

@interface MCiScreenTableViewController_iPad ()

@end

@implementation MCiScreenTableViewController_iPad

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
    
    [[self tableView] setBackgroundColor:[MCColors getbackgroundColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            if ([MCStoreInterface canMakePayments] && ![[MCStoreInterface defaultStoreInterface] isProProductPurchased]) {
                return 2;
            } else {
                return 0;
            }
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
            MCOneLabelTableViewCell_iPad *cell = [tableView dequeueReusableCellWithIdentifier:@"MCOneLabelTableViewCell_iPad" forIndexPath:indexPath];
            [[cell oneTextLabel] setText:@"Restore previous purchases"];
            return cell;
        } else if ([indexPath row] == 1) {
            MCTwoLabelTableViewCell_iPad *cell = [tableView dequeueReusableCellWithIdentifier:@"MCTwoLabelTableViewCell_iPad" forIndexPath:indexPath];
            [[cell leftLabel] setText:@"Buy Pro"];
            [[cell rightLabel] setText:[[[MCStoreInterface defaultStoreInterface] proProduct] priceString]];
            return cell;
        }
    } else if ([indexPath section] == 1) {
        if ([indexPath row] == 0) {
            MCOneLabelTableViewCell_iPad *cell = [tableView dequeueReusableCellWithIdentifier:@"MCOneLabelTableViewCell_iPad" forIndexPath:indexPath];
            [[cell oneTextLabel] setText:@"Feedback"];
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
