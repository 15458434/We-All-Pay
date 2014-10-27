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

typedef NS_ENUM(BOOL, MCUpdateStatus) {
    oldValue,
    newValue
};

@interface TodayViewController () <NCWidgetProviding, NSComboBoxDelegate, NSComboBoxDataSource>

@property (strong) IBOutlet XRCurrencyStoreController *storeController;

@property (nonatomic, strong) NSNumber *sourceAmount;
@property (nonatomic, strong) NSNumber *exchangeRate;
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
@property (nonatomic) MCUpdateStatus exchangeRateUpdateStatus;

@end

@implementation TodayViewController

#pragma mark - Private in this class.

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

- (void)calculateDestinationAmount
{
    [self willChangeValueForKey:@"desintationAmount"];
    self.desintationAmount = @(_sourceAmount.doubleValue * _exchangeRate.doubleValue);
#if DEBUG
    NSLog(@"calculateDestinationAmount: %@", self.desintationAmount);
#endif
    [self didChangeValueForKey:@"desintationAmount"];
}

#pragma mark - Inherited from super.

- (void)awakeFromNib
{
    [super awakeFromNib];
#if DEBUG
    NSLog(@"Good morning says the widget.");
#endif
    _storeController = [XRCurrencyStoreController sharedStore];
    self.sourceAmount = @(1);
    _exchangeRateUpdateStatus = oldValue;
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
    NSOperationQueue *thisQueue = [NSOperationQueue currentQueue];
    typeof(self) weakSelf = self;
    if (_sourceArray.count > 0 && _desintationAmount > 0) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            XRCurrencyXRateFetcher *myFetcher = [strongSelf myXRateFetcher];
            [myFetcher getExchangeRateWithUniqueID:[[NSUUID UUID] UUIDString] from:strongSelf.selectedSourceCurrency.code to:strongSelf.selectedDestinationCurrency.code withCompletionHandler:^(NSDictionary *exchangeRateResult) {
                if (exchangeRateResult) {
#if DEBUG
                    NSLog(@"exchangeRate has been fetched.");
#endif
                    _exchangeRate = [exchangeRateResult objectForKey:XRCurrencyExchangeRate];
#if DEBUG
                    NSLog(@"exchangeRate: %@", _exchangeRate);
#endif
                    [strongSelf calculateDestinationAmount];
                    [thisQueue addOperationWithBlock:^{
                        completionHandler(NCUpdateResultNewData);
                    }];
                } else {
#if DEBUG
                    NSLog(@"exchangeRate has not been fetched.");
#endif
                    [thisQueue addOperationWithBlock:^{
                        completionHandler(NCUpdateResultFailed);
                    }];
                }
            }];
        }
    } else {
        completionHandler(NCUpdateResultNoData);
    }
}

#pragma mark - Combo Box Delegate

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
#if DEBUG
    NSLog(@"%@: comboBoxSelectionDidchange: %@", self, notification);
#endif
    // Get selected source currency
    NSInteger indexOfSelectedSourceCurrency = _sourceCurrencySelector.indexOfSelectedItem;
    if (indexOfSelectedSourceCurrency < 0) {
#if DEBUG
        NSLog(@"selectedSourceCurrency: %ld", (long)indexOfSelectedSourceCurrency);
#endif
        return;
    }
//    NSArray *arrangedSourceCurrencies = _sourceController.arrangedObjects;
    XRCurrency *currentSelectedSourceCurrency = _sourceArray[indexOfSelectedSourceCurrency];
#if DEBUG
    NSLog(@"%@ %@ as source currency selected.", currentSelectedSourceCurrency.name, currentSelectedSourceCurrency.code);
#endif
    // Get selected destination currency
    NSInteger indexOfselectDestinationCurrency = _destinationCurrencySelector.indexOfSelectedItem;
    if (indexOfselectDestinationCurrency < 0) {
#if DEBUG
        NSLog(@"selectedDestinationCurrency: %ld", (long)indexOfselectDestinationCurrency);
#endif
        return;
    }
//    NSArray *arrangedDestinationCurrencies = _destinationController.arrangedObjects;
    XRCurrency *currentSelectedDestinationCurrency = _destinationArray[indexOfselectDestinationCurrency];
#if DEBUG
    NSLog(@"%@ %@ as destination currency selected.", currentSelectedDestinationCurrency.name, currentSelectedDestinationCurrency.code);
#endif
    // Get exchange rate
    NSString *uuidString = [[NSUUID UUID] UUIDString];
    XRCurrencyXRateFetcher *myFetcher = [[XRCurrencyStoreController sharedStore] xRateFetcher];
    __weak typeof(self) weakSelf = self;
    [myFetcher getExchangeRateWithUniqueID:uuidString from:currentSelectedSourceCurrency.code to:currentSelectedDestinationCurrency.code withCompletionHandler:^(NSDictionary *exchangeRateResult) {
#if DEBUG
        NSLog(@"Receiving exchangeRate: %@", exchangeRateResult);
#endif
        _exchangeRate = exchangeRateResult[XRCurrencyExchangeRate];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf calculateDestinationAmount];
        }
    }];
}

#pragma mark - Combo Box Data Source

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    if (aComboBox == _sourceCurrencySelector) {
        return _sourceArray.count;
    }
    if (aComboBox == _destinationCurrencySelector) {
        return _destinationArray.count;
    }
    return 0;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    if (aComboBox == _sourceCurrencySelector) {
        XRCurrency *sourceCurrencyAtIndex = _sourceArray[index];
        return sourceCurrencyAtIndex.name;
    }
    if (aComboBox == _destinationCurrencySelector) {
        XRCurrency *destinationCurrencyAtIndex = _destinationArray[index];
        return destinationCurrencyAtIndex.name;
    }
#if DEBUG
    NSLog(@"There is an unknown comboBox present.");
#endif
    return nil;
}

@end

