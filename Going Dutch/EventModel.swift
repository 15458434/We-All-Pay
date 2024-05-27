//
//  EventModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 06/12/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import UIKit
import Combine

@objc(MCEventModel) final class EventModel: NSObject {
    @objc dynamic var event: MCSharedBill!
    @objc dynamic var mainCurrencyFormatter: CurrencyFormatter!
    @objc var dateFormatter: DateFormatter!
    
    private var bag = Set<AnyCancellable>()
    
    convenience init(andPrepareWith event: MCSharedBill) {
        self.init()
        self.prepareForUse(with: event)
    }
    
    func prepareForUse(with event: MCSharedBill) {
        self.event = event
        self.publisher(for: \.event!.mainCurrency, options: [.initial, .new])
            .sink { [unowned self] currency in
                if let currency, let code = currency.code {
                    self.mainCurrencyFormatter = CurrencyFormatter(currencyCode: code)
                }
            }
            .store(in: &bag)
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
    }
    
    var stringOfApproxPeoplePresent: String {
        let allNamesOfPeoplePresent: [String]
        if #available(iOS 15.0, *) {
            let sortDescriptor: SortDescriptor<MCPerson> = SortDescriptor(\.dateCreated, order: .forward)
            allNamesOfPeoplePresent = event.peoplePresent?.sorted(using: sortDescriptor).map { $0.getName() } ?? [String]()
        } else {
            allNamesOfPeoplePresent = event.peoplePresent?.sorted(by: {
                return $0.dateCreated!.compare($1.dateCreated!) == .orderedDescending
            }).map { $0.getName() } ?? [String]()
        }
        
        if allNamesOfPeoplePresent.count == 0 {
            return NSLocalizedString("event_label_no_people_present", value: "No people present", comment: "A message when there are no people present inside this shared bill")
        } else if allNamesOfPeoplePresent.count == 1 {
            return allNamesOfPeoplePresent[0]
        } else if allNamesOfPeoplePresent.count == 2 {
            let localizedString = NSLocalizedString("event_label_two_people_present", value: "%1$@ and %2$@", comment: "A label showing \"person1 and person2\"")
            return String(format: localizedString, locale: Locale.current, arguments: allNamesOfPeoplePresent)
        } else if allNamesOfPeoplePresent.count >= 3 {
            let localizedString = NSLocalizedString("event_label_three_or_more_people_present", value: "%1$@, %2$@ and others", comment: "A label showing person1, person2 and other")
            return String(format: localizedString, locale: Locale.current, arguments: allNamesOfPeoplePresent)
        } else {
            fatalError("allNamesOfPeoplePresent.count can't be lower than zero")
        }
    }
    
    var totalSumOfMoneySpend: NSDecimalNumber {
        let request: NSFetchRequest<MCPayment> = MCPayment.fetchRequest()
        request.relationshipKeyPathsForPrefetching = ["payingPerson"]
        request.predicate = NSPredicate(format: "onWhichBill = %@ AND ANY peopleSharingPayment.isPersonPresent = YES", event)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MCPayment.dateCreated, ascending: true)]
        let context = event.managedObjectContext!
        let paymentsWithPeoplePresent: [MCPayment] = try! context.fetch(request)
        let result = paymentsWithPeoplePresent.totalSumOfMoneyInMainCurrency
        return result
    }
    
    func reset() {
        if !bag.isEmpty {
            bag.removeAll(keepingCapacity: true)
        }
    }

    // MARK: NSObject
}
