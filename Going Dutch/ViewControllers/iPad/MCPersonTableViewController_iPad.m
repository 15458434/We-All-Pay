//
//  MCPersonViewController_iPadTableViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 03-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCPersonTableViewController_iPad.h"

#import "UINavigationController+KeyboardDismiss.h"

#import "MCPerson+addons.h"
#import "MCSharedBill+addons.h"
#import "MCEmailAddress+addons.h"

#import "MCTonightsBillTransfer.h"
#import "MCDismissMeBlockProtocol.h"

#import "MCWeAllPayStoreController.h"

typedef NS_ENUM(BOOL, MCStatus) {
    inValid,
    valid
};

@interface MCPersonTableViewController_iPad ()

@property (nonatomic) MCStatus emailAddressStringInTextField;

@end

@implementation MCPersonTableViewController_iPad

#pragma mark - Actions

- (IBAction)mainCancelButtonPressed:(id)sender
{
    [[self view] resignFirstResponder];
    mainCancelPressed = cancelIsPressed;
    if ([[[_thisPerson managedObjectContext] undoManager] canUndo]) {
        [[MCWeAllPayStoreController defaultStore] endUndoGroupAndUndo];
    } else {
        [[MCWeAllPayStoreController defaultStore] endUndoGroup];
    }
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)mainDoneButtonPressed:(id)sender
{
    [[self view] resignFirstResponder];
    if ([MCTools isStringAnEmailAddress:[emailField text]]) {
        [self dismissFromDone];
    } else {
        NSString *alertViewTitle = NSLocalizedString(@"INVALID_EMAIL_ADDRESS", "Invalid email address");
        NSString *alertViewMessage = NSLocalizedString(@"INVALID_EMAIL_ADDRESS_MESSAGE", @"The email address you provided doesn't appear to be an email address. This might cause improper behavior. Are you sure you want to continu?");
        NSString *alertViewYes = NSLocalizedString(@"YES", @"yes");
        NSString *alertViewNo = NSLocalizedString(@"NO", @"no");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertViewTitle message:alertViewMessage delegate:self cancelButtonTitle:alertViewNo otherButtonTitles:alertViewYes, nil];
        [alertView show];
    }
    [[MCWeAllPayStoreController defaultStore] saveMainThreadContext];
}

- (IBAction)selectEmailAddressButtonPressed:(id)sender
{
    
}

- (IBAction)backgroundTappedToDismissKeyboard:(id)sender
{
    [self dismissTheKeyboard];
}

#pragma mark - New in this class

- (void)dismissFromDone
{
    NSDate *now = [NSDate date];
    [_tonightsBill setDateModified:now];
    [[MCWeAllPayStoreController defaultStore] endUndoGroupAndProcess];
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)tappedInTheBackground:(id)selector
{
    [self dismissTheKeyboard];
}

- (void) dismissTheKeyboard
{
    if ([firstNameField isFirstResponder]) {
        [firstNameField resignFirstResponder];
    } else if ([lastNameField isFirstResponder]) {
        [lastNameField resignFirstResponder];
    } else if ([emailField isFirstResponder]) {
        [emailField resignFirstResponder];
    }
}

#pragma mark - Inherited From Super

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _emailAddressStringInTextField = inValid;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    isEditingEmailField = isNotEditing;
    mainCancelPressed = cancelIsNotPressed;
    [[MCWeAllPayStoreController defaultStore] beginUndoGroup];
    
    // Make sure a tap in the background dimisses the keyboard as well.
    UITapGestureRecognizer *thatTickles = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedInTheBackground:)];
    [thatTickles setCancelsTouchesInView:NO];
    [[self tableView] addGestureRecognizer:thatTickles];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_thisPerson) {
        _thisPerson = [_tonightsBill addPerson];
        [_thisPerson setPictureDataFromImage:nil];
        [_thisPerson setThumbnailDataFromImage:nil];
//        didSomethingChange = YES;
        isNew = YES;
        NSString *newHeaderTitle = NSLocalizedString(@"NEW_PERSON_HEADER", @"new person");
        [self setTitle:newHeaderTitle];
    } else {
        isNew = NO;
    }
    
    // If there is none or only one emailAddress the button for an email address should not be shown.
    if ([[_thisPerson emailAddress] count] < 2) {
        [selectEmailAddressButton setHidden:YES];
    } else {
        [selectEmailAddressButton setHidden:NO];
    }
    
    [firstNameField setText:[_thisPerson firstName]];
    [lastNameField setText:[_thisPerson lastName]];
    [emailField setText:[_thisPerson defaultEmailAddress]];
    
    _pictureView.image = _thisPerson.picture;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    if (isNew) {
//        [tracker set:kGAIScreenName value:@"MCPersonNewView_iPad"];
//    } else {
//        [tracker set:kGAIScreenName value:@"MCPersonDetailView_iPad"];
//    }
//    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView title] isEqualToString:@"Invalid email address"]) {
        switch (buttonIndex) {
            case 0:
                // don't do anything.
                break;
            case 1:
                [self dismissFromDone];
                break;
            default:
                NSLog(@"This is not supposed to be happening.");
                break;
        }
    }
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

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == emailField) {
        isEditingEmailField = isEditing;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == emailField) {
#if DEBUG
        NSLog(@"should dismiss emailField");
#endif
        if ([MCTools isStringAnEmailAddress:[emailField text]]) {
            [emailField setTextColor:[UIColor blackColor]];
            _emailAddressStringInTextField = valid;
            return YES;
        } else {
            [emailField setTextColor:[UIColor redColor]];
            _emailAddressStringInTextField = inValid;
            return NO;
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // First check is mainCancel has been pressed. In that case this will be executed after the textField has been dismissed.
    if (mainCancelPressed == cancelIsNotPressed) {
        if (textField == firstNameField) {
            [_thisPerson setFirstName:[textField text]];
//            didSomethingChange = YES;
        } else if (textField == lastNameField) {
            [_thisPerson setLastName:[textField text]];
//            didSomethingChange = YES;
        } else if (textField == emailField) {
            if (isNew) {
                [_thisPerson addOneEmailAddressFromAString:[emailField text]];
            } else {
                MCEmailAddress *defaultEmail = [_thisPerson getDefaultEmailAddressObject];
                if (!defaultEmail) {
                    [_thisPerson addOneEmailAddressFromAString:[emailField text]];
                } else {
                    [defaultEmail setEmailAddress:[emailField text]];
                }
            }
//            didSomethingChange = YES;
            isEditingEmailField = isNotEditing;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
