//
//  MCiScreenRootViewController_iPad.m
//  We all pay
//
//  Created by Mark Cornelisse on 25-06-14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

#import "MCiScreenRootViewController_iPad.h"

@interface MCiScreenRootViewController_iPad ()
{
    __weak IBOutlet UILabel *weAllPayVersionLabel;
}
@end

@implementation MCiScreenRootViewController_iPad

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
    
    NSString *versionString = [NSString stringWithFormat:@"We all pay %@ build %@", [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]];
    [weAllPayVersionLabel setText:versionString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
