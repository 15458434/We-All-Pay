//
//  MCPersonViewController_iPadTableViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 03-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCPersonTableViewController_iPad.h"

#import "MCPerson+addons.h"
#import "MCSharedBill+addons.h"

#import "MCTonightsBillTransfer.h"
#import "MCDismissMeBlockProtocol.h"

#import "MCWeAllPayStoreController.h"

@interface MCPersonTableViewController_iPad ()

@end

@implementation MCPersonTableViewController_iPad

#pragma mark - Actions

- (IBAction)mainCancelButtonPressed:(id)sender
{
    if (didSomethingChange) {
        [[MCWeAllPayStoreController defaultStore] endUndoGroupAndUndo];
    } else {
        [[MCWeAllPayStoreController defaultStore] endUndoGroup];
    }
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)mainDoneButtonPressed:(id)sender
{
    [[MCWeAllPayStoreController defaultStore] endUndoGroupAndProcess];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectEmailAddressButtonPressed:(id)sender
{
    
}

#pragma mark - New in this class

- (void)setCircularImageOnPictureView:(UIImage *)image
{
    __weak MCPersonTableViewController_iPad *weakSelf = self;
    
    dispatch_queue_t imageProcessQueue;
    imageProcessQueue = dispatch_queue_create("imageProcessQueue", NULL);
    
    dispatch_async(imageProcessQueue, ^{
        CGRect circularImageRect = CGRectMake(0, 0, 160, 160);
        UIImage *circularImage = [MCTools cutCircularImageFrom:image toDestinationRect:circularImageRect];
        dispatch_async(dispatch_get_main_queue(), ^{
            MCPersonTableViewController_iPad *strongSelf = weakSelf;
            if (strongSelf) {
                [[strongSelf pictureView] setImage:circularImage];
                [[strongSelf pictureView] setNeedsDisplay];
            }
        });
    });
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
    
    didSomethingChange = NO;
    [[MCWeAllPayStoreController defaultStore] beginUndoGroup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_thisPerson) {
        _thisPerson = [_tonightsBill addPerson];
        [_thisPerson setPictureDataFromImage:nil];
        [_thisPerson setThumbnailDataFromImage:nil];
        didSomethingChange = YES;
    }
    [firstNameField setText:[_thisPerson firstName]];
    [lastNameField setText:[_thisPerson lastName]];
    [emailField setText:[_thisPerson defaultEmailAddress]];
    //[_pictureView setImage:[_thisPerson picture]];
    [self setCircularImageOnPictureView:[_thisPerson picture]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverController:(UIPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView *__autoreleasing *)view
{
    
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [emailField setText:[_thisPerson defaultEmailAddress]];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == firstNameField) {
        [_thisPerson setFirstName:[textField text]];
        didSomethingChange = YES;
    } else if (textField == lastNameField) {
        [_thisPerson setLastName:[textField text]];
        didSomethingChange = YES;
    } else if (textField == emailField) {
        NSLog(@"EmailField is not implemented yet.");
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"openSelectEmailAddress"]) {
        id destination = [segue destinationViewController];
        if ([destination conformsToProtocol:@protocol(MCThisPersonProtocol) ]) {
            [destination setThisPerson:_thisPerson];
        }
        
        UIPopoverController *myPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        [myPopover setDelegate:self];
        
        if ([destination conformsToProtocol:@protocol(MCDismissMeBlockProtocol)]) {
            [destination setDismissMe:^{
                [myPopover dismissPopoverAnimated:YES];
                [emailField setText:[_thisPerson defaultEmailAddress]];
            }];
        }
    }
}

@end
