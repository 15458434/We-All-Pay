//
//  TodayViewController.m
//  EMC Widget
//
//  Created by Mark Cornelisse on 23/10/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

@import NotificationCenter;
#import "TodayViewController.h"

#import "XRCurrencyStoreController.h"
#import "XRCurrency.h"
#import "XRCurrencyXRate.h"
#import "XRCurrencyXRateFetcher.h"

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, strong) NSNumber *sourceAmount;
@property (nonatomic, strong) XRCurrencyXRate *exchangeRate;
@property (nonatomic, strong) NSNumber *desintationAmount;

@property (weak) IBOutlet NSTextField *sourceAmountField;
@property (weak) IBOutlet NSComboBox *sourceCurrencySelector;
@property (weak) IBOutlet NSComboBox *destinationCurrencySelector;
@property (weak) IBOutlet NSTextField *destinationAmountField;

@property (strong) IBOutlet NSArrayController *sourceController;
@property (strong) IBOutlet NSArrayController *destinationController;

@property (weak) IBOutlet NSProgressIndicator *activityIndicator;

@property (strong) NSArray *sourceArray;
@property (strong) NSArray *destinationArray;

@property (nonatomic, strong) XRCurrency *selectedSourceCurrency;
@property (nonatomic, strong) XRCurrency *selectedDestinationCurrency;

@property (nonatomic, strong) XRCurrencyXRateFetcher *myXRateFetcher;

@end

@implementation TodayViewController

- (XRCurrencyXRateFetcher *)myXRateFetcher
{
    // if no xratefetcher create one.
    if (!_myXRateFetcher) {
        _myXRateFetcher = [[XRCurrencyXRateFetcher alloc] init];
    }

    return _myXRateFetcher;
}

- (void)setIsFetching:(BOOL)isFetching
{
    if (isFetching) {
        [_activityIndicator startAnimation:self];
        [_destinationAmountField setHidden:YES];
    } else {
        [_activityIndicator stopAnimation:self];
        [_destinationAmountField setHidden:NO];
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
#if DEBUG
    NSLog(@"Widget has been started.");
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setIsFetching:NO];
    
    __weak typeof(self) weakSelf = self;
    // Check for database presence.
    [[XRCurrencyStoreController sharedStore] prepareStoreWithCompletionHandler:^{
        // Setup Currency array's
        NSManagedObjectContext *context = [[XRCurrencyStoreController sharedStore] mainQueueContext];
        self.sourceArray = [[[XRCurrencyStoreController sharedStore] fetchAllCurrenciesForContext:context] copy];
        NSManagedObjectContext *secondeContext = [[XRCurrencyStoreController sharedStore] secondMainQueueContext];
        self.destinationArray = [[[XRCurrencyStoreController sharedStore] fetchAllCurrenciesForContext:secondeContext] copy];
        // TODO: Set the combo boxes to the right value and fetch new exchange rate value.
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            XRCurrencyXRateFetcher *myFetcher = [strongSelf myXRateFetcher];
            [myFetcher getExchangeRateWithUniqueID:[[NSUUID UUID] UUIDString] from:strongSelf.selectedSourceCurrency.code to:strongSelf.selectedDestinationCurrency.code withCompletionHandler:^(NSDictionary *exchangeRateResult) {
#if DEBUG
                NSLog(@"exchangeRate has been fetched.");
#endif
            }];
        }
    }];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    // Fetch current selected exchange rate.
    // Recalculate result
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler {
    // Update your data and prepare for a snapshot. Call completion handler when you are done
    // with NoData if nothing has changed or NewData if there is new data since the last
    // time we called you
    completionHandler(NCUpdateResultNoData);
}

@end

