//
//  MCPayment+addons.m
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

#import "MCPayment+addons.h"
#import "MCPerson.h"
#import "MCSharedBill.h"
#import "MCPaymentPresence+addons.h"
#import "MCCurrency+addons.h"
#import "MCExchangeRate+addons.h"
#import "MCWeAllPayStoreController.h"
#import "MCCategoryPictureStoreController.h"
#import "MCCategoryPictureObject.h"

@implementation MCPayment (addons)

+ (MCPayment *)addPayment
{
    NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
    return [MCPayment addPaymentInContext:context];
}

+ (MCPayment *)addPaymentInContext:(NSManagedObjectContext *)context
{
    MCPayment *newPayment;
    newPayment = [NSEntityDescription insertNewObjectForEntityForName:@"MCPayment" inManagedObjectContext:context];
    [newPayment setUniquePaymentId:[MCTools createUniqueIdentifierString]];
    [newPayment setDateCreated:[NSDate date]];
    [newPayment setDateModified:[newPayment dateCreated]];
    [newPayment setCurrency:[MCCurrency getCurrencySelectedInCurrentLocaleFromContext:context]];
    MCExchangeRate *exchangeRate = [newPayment addExchangeRate];
    [exchangeRate setExchangeRate:@1];
    [exchangeRate setSource:@"Payment Creation"];
    return newPayment;
}

+ (void)deletePayment:(MCPayment *)payment
{
    // Wat te doen met mogelijke sharedBills en personen die aanwezig zijn?
    [[payment managedObjectContext] deleteObject:payment];
}

+ (MCPayment *)fetchPaymentWithUniqueId:(NSString *)uuid
{
    NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
    return [MCPayment fetchPaymentWithUniqueId:uuid fromContext:context];
}

+ (MCPayment *)fetchPaymentWithUniqueId:(NSString *)uuid fromContext:(NSManagedObjectContext *)context
{
    // Create a fetch request for MCSharedBills.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPayment"];
    
    // Select only the sharedBill with uuid as uniqueBillId
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniquePaymentId = %@", uuid];
    [request setPredicate:predicate];
    
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
    NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
    return [self isTableInDatabaseEmptyForContext:context];
}

+ (BOOL)isTableInDatabaseEmptyForContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPayment"];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"money" ascending:YES];
    NSArray *sda = @[sd];
    [request setSortDescriptors:sda];
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
    [paymentPresence setPerson:person];
    [paymentPresence setIsPersonPresent:@YES];
    [paymentPresence setPayment:self];
}

- (void)addLateArrivalPaymentPresenceFor:(MCPerson *)person
{
    // When someone arrives late and is added later to tonightsBill the presence of this person will be set to nil.
    MCPaymentPresence *paymentPresence = [MCPaymentPresence addPaymentPresenceInContext:[self managedObjectContext]];
    [paymentPresence setPerson:person];
    [paymentPresence setIsPersonPresent:@NO];
    [paymentPresence setPayment:self];
    [self setDateModified:[paymentPresence dateCreated]];
}

- (MCPaymentPresence *)fetchPaymentPresenceForPerson:(MCPerson *)person
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPaymentPresence"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"payment = %@ AND person = %@", self, person];
    [request setPredicate:predicate];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"averageOweFromPayment" ascending:YES];
    [request setSortDescriptors:@[sd]];
    
    NSError *error;
    NSArray *fetchResults = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Something went wrong fetching MCPaymentPresence: %@", [error localizedDescription]);
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"payment = %@ AND isPersonPresent = %@", self, @YES];
    [request setPredicate:predicate];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"averageOweFromPayment" ascending:YES];
    [request setSortDescriptors:@[sd]];
    NSError *error;
    NSUInteger *countInteger = [[self managedObjectContext] countForFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Something went wrong counting people present: %@", [error localizedDescription]);
    }
    return [NSNumber numberWithUnsignedInteger:countInteger];
}

- (NSNumber *)averageAmountPeopleShouldHavePaidOnThisPayment
{
    double peoplePresentOnThisPayment = [[self peoplePresentOnThisPayment] doubleValue];
    double result = [[self money] doubleValue] / peoplePresentOnThisPayment;
    return [NSNumber numberWithDouble:result];
}

- (void)recalculateAveragePeopleOweAndStore
{
#if DEBUG
    NSLog(@"%@ recalculateAveragePeopleOweAndStore", self);
#endif
    NSNumber *averagePayedByPeoplePresent = [self averageAmountPeopleShouldHavePaidOnThisPayment];
    NSDate *nu = [NSDate date];
    for (MCPaymentPresence *paymentPresence in [self peopleSharingPayment]) {
        if ([[paymentPresence isPersonPresent] boolValue]) {
            [paymentPresence setAverageOweFromPayment:averagePayedByPeoplePresent];
            [paymentPresence setDateModified:nu];
        } else {
            [paymentPresence setAverageOweFromPayment:@0.00];
            [paymentPresence setDateModified:nu];
        }
    }
    [self setDateModified:nu];
    [[self onWhichBill] setDateModified:nu];
}

- (NSString *)getMoneyValueAsAString
{
    NSNumberFormatter *nf = [[self currency] numberFormatter];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    return [nf stringFromNumber:[self money]];
}

- (NSString *)getMoneyValueInCurrencyAsAString
{
    NSNumberFormatter *nf = [[self currency] numberFormatter];
    [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    return [nf stringFromNumber:[self money]];
}

- (void)putMoneyValueAsAString:(NSString *)moneyString
{
    NSNumberFormatter *nf = [[self currency] numberFormatter];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    [[MCWeAllPayStoreController defaultStore] beginUndoGroupWithoutRegistration];
    [self setMoney:[nf numberFromString:moneyString]];
    [self recalculateAveragePeopleOweAndStore];
    [[MCWeAllPayStoreController defaultStore] endUndoGroupWithoutRegistration];
}

- (void)putMoneyValueInCurrencyAsAString:(NSString *)moneyString
{
    NSNumberFormatter *nf = [[self currency] numberFormatter];
    [nf setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    
    [[MCWeAllPayStoreController defaultStore] beginUndoGroupWithoutRegistration];
    [self setMoney:[nf numberFromString:moneyString]];
    [self recalculateAveragePeopleOweAndStore];
    [[MCWeAllPayStoreController defaultStore] endUndoGroupWithoutRegistration];
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
    [self setExchangeRate:[MCExchangeRate addExchangeRateForContext:[self managedObjectContext]]];
    [[self exchangeRate] setToCurrency:[[self onWhichBill] mainCurrency]];
    [[self exchangeRate] setFromCurrency:[self currency]];
    
    return [self exchangeRate];
}

- (void)setNewCurrencyAndAutomaticallyUpdateExchangeRate:(MCCurrency *)newCurrency
{
    self.currency = newCurrency;
    self.exchangeRate.fromCurrency = newCurrency;
    BOOL success = [[self exchangeRate] retrieveExchangeRateFromWeb];
    if (success) {
        NSLog(@"ExchangeRate retrieval successful");
    } else {
        NSLog(@"ExchangeRate retrieval unsuccesful");
    }
}

- (NSString *)fullDescriptionOfPayment
{
    // Not unit tested, because of multiple languages.
    NSString *categoryName = [[[[MCCategoryPictureStoreController sharedController] pictureObjects] objectAtIndex:self.categoryId.shortValue] categoryDescription];
    NSString *result = [NSString stringWithFormat:@"%@: %@", categoryName, self.descriptionOfPayment];
    return result;
}

#pragma mark - NSManagedObject stuff

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
//    [self setPrimitiveValue:[MCExchangeRate addExchangeRateForContext:[self managedObjectContext]] forKey:@"exchangeRate"];
}

//- (void)didChangeValueForKey:(NSString *)key
//{
//    if ([key isEqualToString:@"peopleSharingPayment"]) {
//        [self recalculateAveragePeopleOweAndStore];
//    }
//}

@end
