//
//  MCSharedBillViewController.m
//  We all pay
//
//  Created by Mark Cornelisse on 02-04-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCSharedBillViewController_iPad.h"

#import "MCPerson+addons.h"
#import "MCSharedBill+addons.h"

#import "MCTools.h"
#import "MCDismissMeBlockProtocol.h"

@interface MCSharedBillViewController_iPad ()

@end

@implementation MCSharedBillViewController_iPad

#pragma mark - Actions

- (IBAction)editButtonPressed:(id)sender
{
    static BOOL isEditingMode = NO;
    NSArray *myKids = [self childViewControllers];
    for (id kid in myKids) {
        if ([kid respondsToSelector:@selector(setEditing:)]) {
            if (isEditingMode) {
                [kid setEditing:NO];
            } else {
                [kid setEditing:YES];
            }
        }
    }
    isEditingMode = !isEditingMode;
}

- (IBAction)addressBookButtonPressed:(id)sender
{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    if (!personReceiver) {
        personReceiver = [[MCAddressBookDataReceiver alloc] initWithViewController:self andDelegate:self];
        [personReceiver setTonightsBill:_tonightsBill];
    }
    [peoplePicker setPeoplePickerDelegate:personReceiver];
    [peoplePicker setEdgesForExtendedLayout:UIRectEdgeNone];
    [[peoplePicker viewControllers][0] setEdgesForExtendedLayout:UIRectEdgeNone];
    [peoplePicker setModalPresentationStyle:UIModalPresentationFormSheet];
    
    // Set the button colors in the navigationBar.
    UIColor *buttonColor = [MCColors getButtonColor];
    [[peoplePicker navigationBar] setTintColor:buttonColor];
    
    // Set the bar color of the navigationBar.
    UIColor *barColor = [MCColors getNavigationColor];
    [[peoplePicker navigationBar] setBarTintColor:barColor];
    
    // Set the titleColor of the navigtionBar.
    UIColor *titleColor = [UIColor whiteColor];
    NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[self navigationController].navigationBar.titleTextAttributes];
    [textAttributes setValue:titleColor forKey:NSForegroundColorAttributeName];
    [[peoplePicker navigationBar] setTitleTextAttributes:textAttributes];

    // Set the background color in the peoplepicker.
    UIColor *backgroundColor = [MCColors getbackgroundColor];
    UISearchBar *addressBookSearchBar = [UISearchBar appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil];
    [addressBookSearchBar setBarTintColor:backgroundColor];
    
    // Set the color of the cancelButton of the search bar
    UIBarButtonItem *addressBookSearchBarCancelButton = [UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil];
    UIColor *addressBookSearchBarCancelButtonColor = [MCColors getButtonColor];
    NSMutableDictionary *colorDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            addressBookSearchBarCancelButtonColor,
                                            NSForegroundColorAttributeName,
                                            nil];
    [colorDictionary setObject:addressBookSearchBarCancelButtonColor forKey:NSForegroundColorAttributeName];
    [addressBookSearchBarCancelButton setTitleTextAttributes:colorDictionary forState:UIControlStateNormal];
    
    // Set the sectionIndex color in the people picker
    UITableView* addressBookTableView = [UITableView appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil];
    UIColor *sectionIndexColor = [MCColors getButtonColor];
    [addressBookTableView setSectionIndexColor:sectionIndexColor];
    
    // Set the sectionColor
    UIView *sectionViewInPicker = [UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], [ABPeoplePickerNavigationController class], nil];
    [sectionViewInPicker setBackgroundColor:[MCColors getbackgroundColor]];
    
    // Set the labelColor of the section in peoplepicker
    UILabel *pickerLabels = [UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil];
    [pickerLabels setTextColor:[MCColors getEmptyMessageTextColor]];
    
    [[self navigationController] presentViewController:peoplePicker animated:YES completion:^{
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"Peoplepicker_iPad"];
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    }];
}


#pragma mark - New in this class

#pragma mark - Inherited From super

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
    // Do any additional setup after loading the view.
    [MCTools setAdBannerIfNotPaid:YES forViewController:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [tripNameField setText:[_tonightsBill tripName]];
    
    // Set the color of the backButton.
    UIColor *backButtonColor = [MCColors getButtonColor];
    [[[self navigationController] navigationBar] setTintColor:backButtonColor];
    [[[self navigationItem] rightBarButtonItem] setTintColor:backButtonColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"MCSharedBillMainViewController_iPad"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MCAddressBookReceiverDelegate

- (MCPerson *)personRecordToUse
{
    return nil;
}

- (void)receiveANewPersonFromAddressBook:(MCPerson *)newPerson
{
    // Not implemented.
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == tripNameField) {
        [_tonightsBill setTripName:[tripNameField text]];
    }
}

#pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // When newPerson segue is used add a person to tonightsBill.
    if ([[segue identifier] isEqualToString:@"newPerson"]) {
        id destination = [[segue destinationViewController] viewControllers][0];
        if ([destination conformsToProtocol:@protocol(MCTonightsBillPut)]) {
            [destination setTonightsBill:_tonightsBill];
        }
        if ([destination conformsToProtocol:@protocol(MCDismissMeBlockProtocol)]) {
            __weak MCSharedBillViewController_iPad *weakSelf = self;
            [destination setDismissMe:^{
                MCSharedBillViewController_iPad *strongSelf = weakSelf;
                if (strongSelf) {
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    [tracker set:kGAIScreenName value:@"MCSharedBillMainViewController_iPad"];
                    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
                }
            }];
        }
    }
    
    // When newPerson segue is used to add a new payment to tonightsbill.
    if ([[segue identifier] isEqualToString:@"newPayment"]) {
        id destination = [[segue destinationViewController] viewControllers][0];
        if ([destination conformsToProtocol:@protocol(MCTonightsBillPut)]) {
            [destination setTonightsBill:_tonightsBill];
        }
        if ([destination conformsToProtocol:@protocol(MCDismissMeBlockProtocol)]) {
            __weak MCSharedBillViewController_iPad *weakSelf = self;
            [destination setDismissMe:^{
                MCSharedBillViewController_iPad *strongSelf = weakSelf;
                if (strongSelf) {
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    [tracker set:kGAIScreenName value:@"MCSharedBillMainViewController_iPad"];
                    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
                }
            }];
        }
    }
    
    // When openSolutionView is used to go to the solution screen.
    if ([[segue identifier] isEqualToString:@"openSolutionView"]) {
        id destination = [[segue destinationViewController] viewControllers][0];
        if ([destination conformsToProtocol:@protocol(MCTonightsBillPut)]) {
            [destination setTonightsBill:_tonightsBill];
        }
        if ([destination conformsToProtocol:@protocol(MCDismissMeBlockProtocol)]) {
            __weak MCSharedBillViewController_iPad *weakSelf = self;
            [destination setDismissMe:^{
                MCSharedBillViewController_iPad *strongSelf = weakSelf;
                if (strongSelf) {
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                        [tracker set:kGAIScreenName value:@"MCSharedBillMainViewController_iPad"];
                        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
                    }];
                }
            }];
        }
    }
}

@end
