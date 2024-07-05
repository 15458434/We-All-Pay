//
//  MCPayment+addons.m
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import FirebaseCrashlytics;

#import "MCPayment+addons.h"
#import "MCPerson.h"
#import "MCSharedBill.h"
#import "MCPaymentPresence+addons.h"
#import "MCCurrency+addons.h"
#import "MCExchangeRate+addons.h"

#import "We_all_pay-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@implementation MCPayment (addons)

+ (MCPayment *)addPayment
{
    NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] viewContext];
    return [MCPayment addPaymentInContext:context];
}

+ (MCPayment *)addPaymentInContext:(NSManagedObjectContext *)context {
    BOOL isContextPresent = context ? YES : NO;
    [[FIRCrashlytics crashlytics] logWithFormat:@"isContextPresent: %@", @(isContextPresent)];
    MCPayment *newPayment = [NSEntityDescription insertNewObjectForEntityForName:@"MCPayment" inManagedObjectContext:context];
    newPayment.uniquePaymentId = [[NSUUID UUID] UUIDString];
    newPayment.dateCreated = [NSDate date];
    newPayment.dateModified = newPayment.dateCreated;
    newPayment.currency = [MCCurrency generateCurrencyFromSelectedLocaleForContext:context];
    MCExchangeRate *exchangeRate = [newPayment addExchangeRate];
    exchangeRate.exchangeRate = @1;
    exchangeRate.source = @"Payment Creation";
    return newPayment;
}

+ (void)deletePayment:(MCPayment *)payment
{
    // Wat te doen met mogelijke sharedBills en personen die aanwezig zijn?
    [[payment managedObjectContext] deleteObject:payment];
}

+ (MCPayment *)fetchPaymentWithUniqueId:(NSString *)uuid
{
    NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] viewContext];
    return [MCPayment fetchPaymentWithUniqueId:uuid fromContext:context];
}

+ (MCPayment *)fetchPaymentWithUniqueId:(NSString *)uuid fromContext:(NSManagedObjectContext *)context
{
    // Create a fetch request for MCSharedBills.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPayment"];
    
    // Select only the sharedBill with uuid as uniqueBillId
    request.predicate = [NSPredicate predicateWithFormat:@"uniquePaymentId = %@", uuid];
    
    NSError *error;
    NSArray *payments = [context executeFetchRequest:request error:&error];
    if (!payments) {
        // There was an error.
        return nil;
    } else {
        return payments[0];
    }
}

+ (BOOL)isTableInDatabaseEmpty
{
    NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] viewContext];
    return [self isTableInDatabaseEmptyForContext:context];
}

+ (BOOL)isTableInDatabaseEmptyForContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPayment"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"money" ascending:YES]];
    
    NSError *error;
    
    NSArray *allPayments = [context executeFetchRequest:request error:&error];
    if (allPayments) {
        if ([allPayments count] == 0) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (BOOL)hasPayer
{
    if ([self payingPerson]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)addPaymentPresenceFor:(MCPerson *)person
{
    // When the App goes through an update cycle to version two for eacht payment the presences need to be added.
    MCPaymentPresence *paymentPresence = [MCPaymentPresence addPaymentPresenceInContext:[self managedObjectContext]];
    
    paymentPresence.person = person;
    [person addSharingPaymentObject:paymentPresence];
    
    paymentPresence.isPersonPresent = @YES;
    
    paymentPresence.payment = self;
    [self addPeopleSharingPaymentObject:paymentPresence];
}

- (void)addLateArrivalPaymentPresenceFor:(MCPerson *)person
{
    // When someone arrives late and is added later to tonightsBill the presence of this person will be set to nil.
    MCPaymentPresence *paymentPresence = [MCPaymentPresence addPaymentPresenceInContext:[self managedObjectContext]];
    
    paymentPresence.person = person;
    [person addSharingPaymentObject:paymentPresence];
    
    paymentPresence.isPersonPresent = @NO;
    
    paymentPresence.payment = self;
    [self addPeopleSharingPaymentObject:paymentPresence];
    
    paymentPresence.dateModified = paymentPresence.dateCreated;
}

- (MCPaymentPresence *)fetchPaymentPresenceForPerson:(MCPerson *)person
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPaymentPresence"];
    request.predicate = [NSPredicate predicateWithFormat:@"payment = %@ AND person = %@", self, person];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"averageOweFromPayment" ascending:YES]];
    
    NSError *error;
    NSArray *fetchResults = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Something went wrong fetching MCPaymentPresence: %@", error);
    }
    return [fetchResults objectAtIndex:0];
}

- (void)thisPerson:(MCPerson *)person setIsPresent:(NSNumber *)isPresent
{
    MCPaymentPresence *thisPersonsPresence = [self fetchPaymentPresenceForPerson:person];
    [[MCWeAllPayStoreController defaultStore] beginUndoGroupWithoutRegistration];
    [thisPersonsPresence setIsPersonPresent:isPresent];
    [self recalculateAveragePeopleOweAndStore];
    [[MCWeAllPayStoreController defaultStore] endUndoGroupWithoutRegistration];
}

- (NSNumber *)peoplePresentOnThisPayment
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPaymentPresence"];
    request.predicate = [NSPredicate predicateWithFormat:@"payment = %@ AND isPersonPresent = %@", self, @YES];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"averageOweFromPayment" ascending:YES]];
    NSError *error;
    NSUInteger countInteger = [[self managedObjectContext] countForFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Something went wrong counting people present: %@", error);
    }
    return [NSNumber numberWithUnsignedInteger:countInteger];
}

- (NSNumber *)averageAmountPeopleShouldHavePaidOnThisPayment
{
    double peoplePresentOnThisPayment = self.peoplePresentOnThisPayment.doubleValue;
    double result = self.money.doubleValue / peoplePresentOnThisPayment;
    return @(result);
}

- (void)recalculateAveragePeopleOweAndStore
{
#ifdef DEBUG
    NSLog(@"recalculateAveragePeopleOweAndStore: %@", self);
#endif
    NSNumber *averagePayedByPeoplePresent = [self averageAmountPeopleShouldHavePaidOnThisPayment];
    NSDate *now = [NSDate date];
    for (MCPaymentPresence *paymentPresence in [self peopleSharingPayment]) {
        if (paymentPresence.isPersonPresent.boolValue) {
            paymentPresence.averageOweFromPayment = averagePayedByPeoplePresent;
            paymentPresence.dateModified = now;
        } else {
            paymentPresence.averageOweFromPayment = @0.00;
            paymentPresence.dateModified = now;
        }
    }
    self.dateModified = now;
    self.onWhichBill.dateModified = now;
}

- (NSNumber *)moneyInMainCurrency
{
    if (![self exchangeRate]) {
        NSLog(@"Bazinga");
    }
    double moneyDouble = [[self money] doubleValue];
    double exchangeRateDouble = [[[self exchangeRate] exchangeRate] doubleValue];
    return @(moneyDouble * exchangeRateDouble);
}

- (MCExchangeRate *)addExchangeRate
{
    MCExchangeRate *new = [MCExchangeRate addExchangeRateForContext:[self managedObjectContext]];
    
    self.exchangeRate = new;
    new.payment = self;
    
    self.exchangeRate.toCurrency = self.onWhichBill.mainCurrency;
    [self.onWhichBill.mainCurrency addExchangeRateToCurrencyObject:self.exchangeRate];
    
    self.exchangeRate.fromCurrency = self.currency;
    [self.currency addExchangeRateFromCurrencyObject:self.exchangeRate];
    
    return [self exchangeRate];
}

- (void)setNewCurrencyAndAutomaticallyUpdateExchangeRate:(MCCurrency *)newCurrency withCompletionHandler:(void (^)(NSError * _Nullable))completionHandler
{
    self.currency = newCurrency;
    self.exchangeRate.fromCurrency = newCurrency;
    [[self exchangeRate] fetchExchangeRate:^(NSError *error) {
        if (error) {
            completionHandler(error);
            return;
        }
        [self recalculateAveragePeopleOweAndStore];
        completionHandler(nil);
    }];
}

- (NSString *)fullDescriptionOfPayment
{
    // Not unit tested, because of multiple languages.
    if (!self.descriptionOfPayment) {
        NSString *result = NSLocalizedStringWithDefaultValue(@"payment_view_no_full_description", nil, NSBundle.mainBundle, @"Something", @"A term that replaced the description of an a payment when no description is entered in the payment.");
        return result;
    } else if (self.categoryId.shortValue == 0) {
        return [NSString stringWithFormat:@"%@", self.descriptionOfPayment];
    } else {
        NSString *categoryName = CategoryPictureStoreController.shared.pictureObjects[self.categoryId.shortValue].categoryDescription;
        NSString *result = [NSString stringWithFormat:@"%@: %@", categoryName, self.descriptionOfPayment];
        return result;
    }

}

#pragma mark - NSManagedObject stuff

@end

NS_ASSUME_NONNULL_END
