//
//  MCSharedBill+addons.m
//  We all pay
//
//  Created by Mark Cornelisse on 14-09-13.
//  Copyright (c) 2013 Mark Cornelisse. All rights reserved.
//

@import FirebaseCrashlytics;

#import "MCSharedBill+addons.h"
#import "MCPerson+addons.h"
#import "MCEmailAddress+addons.h"
#import "MCPayment+addons.h"
#import "MCPaymentPresence+addons.h"
#import "MCWeAllPayStoreController.h"
#import "MCCurrency+addons.h"
#import "MCExchangeRate+addons.h"

#import "We_all_pay-Swift.h"

@implementation MCSharedBill (addons)

#pragma mark - New in this class.

+ (MCSharedBill *)addSharedBill
{
    NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
    return [MCSharedBill addSharedBillToContext:context];
}

+ (MCSharedBill *)addSharedBillToContext:(NSManagedObjectContext *)context
{
    MCSharedBill *sharedBill = [NSEntityDescription insertNewObjectForEntityForName:@"MCSharedBill" inManagedObjectContext:context];
    sharedBill.uniqueBillId = [[NSUUID UUID] UUIDString];
    sharedBill.hasTheMailBeenSent = @NO;
    NSDate *now = [NSDate date];
    sharedBill.dateCreated = now;
    sharedBill.dateModified = now;
    sharedBill.mainCurrency = [MCCurrency generateCurrencyFromSelectedLocaleForContext:context];
    return sharedBill;
}

+ (void)deleteSharedbill:(MCSharedBill *)deleteBill
{
    NSManagedObjectContext *context = [deleteBill managedObjectContext];
    // Delete all paymentPresences of all payments.
    for (MCPayment *payment in [deleteBill payments]) {
        for (MCPaymentPresence *paymentPresence in [payment peopleSharingPayment]) {
            [context deleteObject:paymentPresence];
        }
    }
    // Delete all payments of the to be deleted sharedbill
    for (MCPayment *payment in [deleteBill payments]) {
        [context deleteObject:payment];
    }
    // Delete all emailaddresses of all people of the sharedbill.
    for (MCPerson *person in [deleteBill peoplePresent]) {
        for (MCEmailAddress *emailAddress in [person emailAddress]) {
            [context deleteObject:emailAddress];
        }
    }
    // Delete all people of the sharedbill.
    for (MCPerson *person in [deleteBill peoplePresent]) {
        [context deleteObject:person];
    }
    // Delete the sharedBill itself.
    [context deleteObject:deleteBill];
}

+ (MCSharedBill *)fetchSharedBillWithUniqueId:(NSString *)uuid inContext:(NSManagedObjectContext *)context
{
    // Create a fetch request for MCSharedBills.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCSharedBill"];
    
    // Select only the sharedBill with uuid as uniqueBillId
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueBillId = %@", uuid];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *sharedBills = [context executeFetchRequest:request error:&error];
    if (!sharedBills) {
        // There was an error.
        return nil;
    } else {
        if (sharedBills.count > 0) {
            return sharedBills[0];
        } else {
            return nil;
        }
    }
}

+ (BOOL)isTableInDatabaseEmpty
{
    NSManagedObjectContext *context = [[MCWeAllPayStoreController defaultStore] mainThreadContext];
    return [self isTableInDatabaseEmptyForContext:context];
}

+ (BOOL)isTableInDatabaseEmptyForContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCSharedBill"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES];
    NSArray *sortDescriptorArray = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptorArray];

    NSError *error;
    NSArray *people = [context executeFetchRequest:request error:&error];
    if (people) {
        if ([people count] == 0) {
            return YES;
        } else {
#ifdef DEBUG
            NSLog(@"sharedBills.count should not be 0.");
#endif
            return NO;
        }
    } else {
        return NO;
    }
}

- (MCPayment *)addPayment
{
    MCPayment *payment = [MCPayment addPaymentInContext:self.managedObjectContext];
    for (MCPerson *person in [self peoplePresent]) {
        MCPaymentPresence *paymentPresence = [MCPaymentPresence addPaymentPresenceInContext:self.managedObjectContext];
        
        paymentPresence.payment = payment;
        [payment addPeopleSharingPaymentObject:paymentPresence];
        
        paymentPresence.person = person;
        [person addSharingPaymentObject:paymentPresence];
        
        paymentPresence.isPersonPresent = @(YES);
    }
    
    [self addPaymentsObject:payment];
    payment.onWhichBill = self;
    
    payment.exchangeRate.toCurrency = [self mainCurrency];
    [self.mainCurrency addExchangeRateToCurrencyObject:payment.exchangeRate];
    
    return payment;
}

- (void)deletePayment:(MCPayment *)toBeDeletePayment
{
    // It is not allowed to delete a payment belonging to another sharedBill.
    NSParameterAssert([toBeDeletePayment onWhichBill] == self);
    
    // First delete the people presence on payment data.
    NSSet *paymentPresences = [toBeDeletePayment peopleSharingPayment];
    for (MCPaymentPresence *paymentPresence in paymentPresences) {
        [[self managedObjectContext] deleteObject:paymentPresence];
    }
    
    // Then delete the payment.
    [[self managedObjectContext] deleteObject:toBeDeletePayment];
    
}

- (void)updatePaymentForSupportWithPaymentPresence
{
    // Always executed to maintain unit test compatibility.
    for (MCPayment *payment in [self payments]) {
        [payment recalculateAveragePeopleOweAndStore];
    }
}

- (MCPerson *)addPerson {
    NSArray *keysToExtract = @[@"tripName", @"uniqueBillId"];
    NSDictionary *selfAsADictionary = [self dictionaryWithValuesForKeys:keysToExtract];
    [[FIRCrashlytics crashlytics] logWithFormat:@"add person on sharedBill: %@", selfAsADictionary];
    NSManagedObjectContext *context = [self managedObjectContext];
    BOOL isContextPresent = context ? YES : NO;
    [[FIRCrashlytics crashlytics] logWithFormat:@"isContextPresent: %@", @(isContextPresent)];
    
    MCPerson *newPerson = [MCPerson addPersonInContext:context];
    for (MCPayment *payment in [self payments]) {
        // Presence of all the exisiting payments on this sharedBill will be created and set tot NO.
        [payment addLateArrivalPaymentPresenceFor:newPerson];
    }
    [newPerson addSharedBillObject:self];
    [self addPeoplePresentObject:newPerson];
    
    return newPerson;
}

- (void)deletePerson:(MCPerson *)toBeDeletedPerson
{
    NSSet *presences = [[toBeDeletedPerson sharingPayment] copy];
    for (MCPaymentPresence *paymentPresence in presences) {
        MCPayment *payment = [paymentPresence payment];
        [[self managedObjectContext] deleteObject:paymentPresence];
        [payment recalculateAveragePeopleOweAndStore];
    }
    [MCPerson deletePerson:toBeDeletedPerson];
}

- (MCPerson *)fetchPersonWithUniqueID:(NSString *)uuid
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"ANY sharedBill = %@ AND uniquePersonId = %@", self, uuid];
    NSError *fetchError;
    NSArray *result = [context executeFetchRequest:request error:&fetchError];
    if (!result) {
        NSLog(@"Error fetching person with id:%@", uuid);
        NSLog(@"%@", fetchError.description);
        return nil;
    } else {
        return result.firstObject;
    }
}

- (BOOL)isPresentWithFirstName:(NSString *)firstName andLastName:(NSString *)lastName andEmailAddress:(NSString *)emailAddress
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    NSArray *sda = @[sortDescriptor1, sortDescriptor2];
    [request setSortDescriptors:sda];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY sharedBill = %@ AND firstName = %@ AND lastName = %@ AND ANY emailAddress.emailAddress = %@", self, firstName, lastName, emailAddress];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *result = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (!result) {
        NSLog(@"Error checking if person is present: %@", error);
        return NO;
    } else {
        if ([result count] == 0) {
            return NO;
        } else {
            return YES;
        }
    }
}

- (BOOL)areTherePeople
{
    if ([[self peoplePresent] count] == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (NSUInteger)totalAmountOfPeoplePresent
{
    return [[self peoplePresent] count];
}

- (NSUInteger)totalAmountOfPeopleWhoHavePaid
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPerson"];
    request.predicate = [NSPredicate predicateWithFormat:@"some payments.onWhichBill == %@", self];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"uniquePersonId" ascending:YES]];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error = nil;
    NSUInteger result = [context countForFetchRequest:request error:&error];
    if (error) {
        NSLog(@"totalAmountOfPeopleWhoHavPaid fetch error: %@", error);
        return 0;
    } else {
        return result;
    }
}

- (NSNumber *)totalSumOfMoneyOfThisSharedBill
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPayment"];
    [request setRelationshipKeyPathsForPrefetching:@[ @"payingPerson" ]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"onWhichBill = %@ AND ANY peopleSharingPayment.isPersonPresent = YES", self]];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]]];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error = nil;
    NSArray *paymentsOfPerson = [context executeFetchRequest:request error:&error];
    if (!paymentsOfPerson) {
        NSLog(@"Error fetching paymentofPerson: %@", error);
    }
    return [paymentsOfPerson valueForKeyPath:@"@sum.moneyInMainCurrency"];
}

- (NSArray<MCPerson *> *)fetchPeoplePresentOrderedByAmountPaid:(BOOL)ascending
{
    NSSet *people = [self peoplePresent];
    NSArray *sortedPeople = [people sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"totalSumPaid" ascending:ascending] ]];
    return sortedPeople;
}

- (NSNumber *)totalAmountOfCreditBy:(MCPerson *)person
{
    double totalSumPaid = [[self totalSumPaidBy:person] doubleValue];
    double average = [[self amountPeopleShouldHavePaid] doubleValue];
    double credit = totalSumPaid - average;
    return @(credit);
}

- (NSNumber *)totalSumPaidBy:(MCPerson *)person
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPayment"];
    request.relationshipKeyPathsForPrefetching = @[@"payingPerson" ];
    request.predicate = [NSPredicate predicateWithFormat:@"onWhichBill = %@ AND payingPerson = %@ AND ANY peopleSharingPayment.isPersonPresent = YES", self, person];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    NSError *error = nil;
    NSArray *paymentsOfPerson = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (!paymentsOfPerson) {
        NSLog(@"Error fetching paymentofPerson: %@", error);
    }
    return [paymentsOfPerson valueForKeyPath:@"@sum.moneyInMainCurrency"];
}

- (BOOL)hasPersonPaidSomething:(MCPerson *)person
{
    NSNumber *paid = [self totalSumPaidBy:person];
    if ([paid doubleValue] < 0.01) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)doesEveryoneHaveAnEmailAddress
{
    for (MCPerson *person in [self peoplePresent]) {
        if (![person isThereAnEmailAddress]) {
            return NO;
        }
    }
    return YES;
}

- (NSNumber *)amountPeopleShouldHavePaid
{
    double sumOfMoney = [[self totalSumOfMoneyOfThisSharedBill] doubleValue];
    if ([[self peoplePresent] count] > 0) {
        double average = sumOfMoney / [[self peoplePresent] count];
        return @(average);
    } else {
        return @0.0;
    }
}

- (NSNumber *)amountShouldHavePaidBy:(MCPerson *)person
{
    // Fetch the sum of all paymentPresences for person
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MCPaymentPresence"];
    request.predicate = [NSPredicate predicateWithFormat:@"payment.onWhichBill = %@ AND person = %@ AND isPersonPresent = %@", self, person, @YES];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"person" ascending:YES]];

    NSError *error;
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Something went wrong fetching sumOfAverageFromEachPayment: %@", error);
    }
    
    double sumOfAllOwes = 0;
    for (MCPaymentPresence *paymentPresence in results) {
        sumOfAllOwes += [[paymentPresence getAverageOweFromPaymentInMainCurrency] doubleValue];
    }
    
    return @(sumOfAllOwes);
}

- (BOOL)doAllPaymentsHaveAPayer {
    // Query that checks to see if all the payments have a payer.
    NSFetchRequest *request = MCPayment.fetchRequest;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"onWhichBill = %@ AND payingPerson = %@", self, [NSNull null]];
    NSError *countError;
    NSUInteger amountOfPaymentWithoutPayers = [[self managedObjectContext] countForFetchRequest:request error:&countError];
    if (countError) {
        NSLog(@"Something went wrong counting payments without payers: %@", countError);
    }
    if (amountOfPaymentWithoutPayers > 0) {
        return NO;
    } else {
        return YES;
    }
}

- (MCPayment *)getFirstPaymentWithoutAPayer
{
    // Returns the first payment without a payer on this sharedBill.
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MCPayment"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"onWhichBill = %@ AND payingPerson = %@", self, nil];
    NSError *fetchError;
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"Error fetching firstPayment without a payer.");
        return nil;
    }
    return (MCPayment *)results.firstObject;
}

- (BOOL)areAllExchangeRatesValid
{
    // Fetch all exchangeRates that are invalid.
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MCExchangeRate"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    
    NSNumber *exchangeRateValidStatus = [NSNumber numberWithShort:MCExchangeRateStatusValid];
    request.predicate = [NSPredicate predicateWithFormat:@"payment.onWhichBill = %@ and status != %@", self, exchangeRateValidStatus];
    NSError *fetchError;
    NSUInteger amountOfInvalidExchangeRates = [[self managedObjectContext] countForFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"Something went wrong counting invalid exchangeRates: %@", fetchError);
    }
    if (amountOfInvalidExchangeRates == 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)updateMainCurrencyFromCode:(NSString *)code withCompletion:(void (^)(NSError *error))completion {
    MCCurrency *newMainCurrency = [MCCurrency currencyFrom:code fromContext:self.managedObjectContext];
    self.mainCurrency = newMainCurrency;
    NSArray<MCExchangeRate *> *allExchangeRates = [self fetchAllExchangeRatesWithError:nil];
    [allExchangeRates enumerateObjectsUsingBlock:^(MCExchangeRate * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.toCurrency = newMainCurrency;
    }];
    [self updateAllExchangeRatesWithCompletionHandler:completion];
}

- (NSArray<MCExchangeRate *> *)fetchAllExchangeRatesWithError:(NSError **)error {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MCExchangeRate"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"payment.onWhichBill = %@", self];
    
    NSError *fetchError;
    NSArray<MCExchangeRate *> *arrayOfAllExchangeRates = [[self managedObjectContext] executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        *error = fetchError;
        NSLog(@"Something went wrong fetching all ExchangeRates on this bill: %@", fetchError.localizedDescription);
        return nil;
    }
    
    return arrayOfAllExchangeRates;
}

- (void)updateAllExchangeRatesWithCompletionHandler:(void (^)(NSError *error))completion {
    NSError *fetchError;
    NSArray<MCExchangeRate *> *arrayOfAllExchangeRates = [self fetchAllExchangeRatesWithError:&fetchError];
    if (fetchError) {
        NSLog(@"Something went wrong fetching all ExchangeRates on this bill: %@", fetchError);
        completion(fetchError);
        return;
    }
    
    [arrayOfAllExchangeRates enumerateObjectsUsingBlock:^(MCExchangeRate * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.status = @(MCExchangeRateStatusInvalid);
    }];
    
    NSError *saveError;
    [[self managedObjectContext] save:&saveError];
    if (saveError) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Error saving arrayOfAllExchangeRates" userInfo:@{@"saved Array": arrayOfAllExchangeRates}];
    }
    
    [self updateInvalidExchangeRatesWithHandler:^(NSArray *results, NSError *error) {
        completion(error);
    }];
}

- (void)updateInvalidExchangeRatesWithHandler:(void (^)(NSArray *results, NSError *error))completion
{
    // Fetch all exchangeRates that are invalid.
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MCExchangeRate"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    
    NSNumber *exchangeRateValidStatus = [NSNumber numberWithShort:MCExchangeRateStatusValid];
    request.predicate = [NSPredicate predicateWithFormat:@"payment.onWhichBill = %@ and status != %@", self, exchangeRateValidStatus];
    NSError *fetchError;
    NSArray *arrayOfInvalidExchangeRatesOfThisSharedBill = [[self managedObjectContext] executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"Something went wrong fetching invalid ExchangeRates: %@", fetchError);
        completion(nil, fetchError);
        return;
    }
    for (MCExchangeRate *exchangeRate in arrayOfInvalidExchangeRatesOfThisSharedBill) {
        exchangeRate.status = [NSNumber numberWithShort:MCExchangeRateStatusFetching];
    }
    [[[MCWeAllPayStoreController defaultStore] fetcher] fetchAll:arrayOfInvalidExchangeRatesOfThisSharedBill completionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Something went wrong fetching exchangeRates.");
            completion(nil, error);
        }
        if ([self areAllExchangeRatesValid]) {
            NSError *saveError;
            [[[MCWeAllPayStoreController defaultStore] mainThreadContext] save:&saveError];
            completion([self solveWhoHasToPayWhoFromThisBill], saveError);
        } else {
            NSError *notAllExchangeRatesValidError = [NSError errorWithDomain:@"com.green.We_all_pay" code:1 userInfo:@{@"reason": @"Not all exchangeRates are valid after fetching exchangeRates"}];
            completion(nil, notAllExchangeRatesValidError);
        }
    }];
}

- (NSArray *)originalSolveWhoHasToPayWhoFromThisBill
{
    // Create two array's one of peope who should pay and one with people that should receive.
    NSMutableArray *payers = [[NSMutableArray alloc] init];
    NSNumber *leftToPay;
    NSNumber *leftToReceive;
    NSMutableArray *receivers = [[NSMutableArray alloc] init];
    NSMutableArray<MCReturnPayment *> *whoHasToPayWho = [[NSMutableArray alloc] init];
    NSArray *sortDescriptorArray1 = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]];
    NSArray<MCPerson *> *people = [[self peoplePresent] sortedArrayUsingDescriptors:sortDescriptorArray1];
    
    // Update the database to the current version.
    [self updatePaymentForSupportWithPaymentPresence];
    
    for (MCPerson *person in people) {
        NSNumber *sumOfWhatWasPaidByPerson = [self totalSumPaidBy:person];
        NSNumber *sumOfWhatShouldBePaidPerson = [self amountShouldHavePaidBy:person];
        
        if ([sumOfWhatWasPaidByPerson doubleValue] < [sumOfWhatShouldBePaidPerson doubleValue]) {
            // This person should pay to someone.
            leftToPay = @([sumOfWhatShouldBePaidPerson doubleValue] - [sumOfWhatWasPaidByPerson doubleValue]);
            NSArray *creditValueOfThisPerson = [[NSMutableArray alloc] initWithObjects:person, sumOfWhatShouldBePaidPerson, sumOfWhatWasPaidByPerson, leftToPay, nil];
            [payers addObject:creditValueOfThisPerson];
        } else if ([sumOfWhatWasPaidByPerson doubleValue] > [sumOfWhatShouldBePaidPerson doubleValue]){
            // This person should receive from someone.
            leftToReceive = @([sumOfWhatWasPaidByPerson doubleValue] - [sumOfWhatShouldBePaidPerson doubleValue]);
            NSArray *creditValueOfThisPerson = [[NSMutableArray alloc] initWithObjects:person, sumOfWhatShouldBePaidPerson, sumOfWhatWasPaidByPerson, leftToReceive, nil];
            [receivers addObject:creditValueOfThisPerson];
        } else {
            // This person has already paid enough.
//            MCReturnPayment *notDepted = [[MCReturnPayment alloc] initWithPayer:person paysTo:nil amountOfMoney:@0.00];
//            [whoHasToPayWho addObject:notDepted];
        }
    }
    
    // Solve who has to pay who.
    if ([payers count] > 0) {
        for (NSMutableArray *payer in payers) {
            for (NSMutableArray *receiver in receivers) {
                double ltp = [payer[3] doubleValue];
                double ltr = [receiver[3] doubleValue];
                MCReturnPayment *returnPayment;
                if (ltp >= ltr) {
                    returnPayment = [[MCReturnPayment alloc] initWithPayer:payer[0] money:@(ltr) receiver:receiver[0]];
                    ltp -= ltr;
                    ltr = 0;
                } else {
                    returnPayment = [[MCReturnPayment alloc] initWithPayer:payer[0] money:@(ltp) receiver:receiver[0]];
                    ltr -= ltp;
                    ltp = 0;
                }
                leftToPay = @(ltp);
                leftToReceive = @(ltr);
                payer[3] = leftToPay;
                receiver[3] = leftToReceive;
                
                if ([[returnPayment money] doubleValue] > 0) {
                    [whoHasToPayWho addObject:returnPayment];
                }
            }
        }
    } else {
    }
    return whoHasToPayWho;
}

- (NSArray *)solveWhoHasToPayWhoFromThisBill
{
    return [self originalSolveWhoHasToPayWhoFromThisBill];
}

- (void)solveWithHandler:(void (^)(NSArray *results, NSError *error))solution {
    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
    if ([self areAllExchangeRatesValid]) {
        NSArray<MCReturnPayment *> *results = [self originalSolveWhoHasToPayWhoFromThisBill];
        [currentQueue addOperationWithBlock:^{
            solution(results, nil);
        }];
    } else {
        [self updateInvalidExchangeRatesWithHandler:^(NSArray *results, NSError *error) {
            if (error) {
                solution(nil, error);
            } else {
                NSArray *results = [self originalSolveWhoHasToPayWhoFromThisBill];
                solution(results, nil);
            }
        }];
    }
}

- (NSArray<MCPerson *> *)getArrayOfPeopleSortedOnFullNames
{
    NSArray<MCPerson *> *unsortedPeople = [[self peoplePresent] allObjects];
    return [[UILocalizedIndexedCollation currentCollation] sortedArrayFromArray:unsortedPeople collationStringSelector:@selector(getFullName)];
}

- (void)deleteIfStillNew
{
    // Check to see if tripname is still 0 in length or nil.
    if (![self tripName] || [[self tripName] length] == 0) {
            // Check to see if payments count is still 0
        if ([[self payments] count] == 0) {
            // Check to see if people present is still 0
            if ([[self peoplePresent] count] == 0) {
                [MCSharedBill deleteSharedbill:self];
            }
        }
    }
}

- (NSArray<MCCurrency *> *)recentUsedForeignCurrencies:(NSUInteger)fetchLimit
{
    // Prepare NSFetchRequest
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MCCurrency"];
    if (fetchLimit > 0) {
        request.fetchLimit = fetchLimit * 2;
    }
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO]];
    request.predicate = [NSPredicate predicateWithFormat:@"ANY payment.onWhichBill.uniqueBillId LIKE %@ AND NOT code LIKE %@", self.uniqueBillId, self.mainCurrency.code];
    
    // Execute fetch request
    NSError *fetchError;
    NSManagedObjectContext *context = self.managedObjectContext;
    NSArray<MCCurrency *> *results = (NSArray<MCCurrency *> *)[context executeFetchRequest:request error:&fetchError];
    
    // Parse results.
    if (fetchError) {
#ifdef DEBUG
        NSLog(@"Error fetching recentUsedCurrencies: %@", fetchError.description);
#endif
        return nil;
    }
    
    if (results.count <= 1) {
        return results;
    }
    
    NSMutableArray *resultsCopy = [NSMutableArray array];
    NSMutableSet *codes = [NSMutableSet set];
    for (MCCurrency *currency in results) {
        NSString *code = currency.code;
        if (![codes containsObject:code]) {
            [resultsCopy addObject:currency];
            [codes addObject:code];
        }
    }
    
    if (resultsCopy.count > 5) {
        return [resultsCopy subarrayWithRange:NSMakeRange(0, 5)];
    } else {
        return resultsCopy;
    }
}

#pragma mark - NSManagedObject Stuff

@end
