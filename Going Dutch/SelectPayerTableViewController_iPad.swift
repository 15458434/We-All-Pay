//
//  SelectPayerTableViewController_iPad.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/10/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import UIKit
import CoreData

import FirebaseAnalytics

final class SelectPayerTableViewController_iPad: UITableViewController {
    // TODO: Rename to 'sortedPeople'. It indicates better what it does.
    @objc dynamic private var people: [MCPerson]!
    private weak var eventModel: EventModel!
    private weak var paymentModel: PaymentModel!
    @objc(writableTonightsBill) var writableTonightsBill: MCSharedBill!
    
    func prepareForUse(eventModel: EventModel, paymentModel: PaymentModel) {
        self.eventModel = eventModel
        self.paymentModel = paymentModel
    }
    
    // MARK: UITableViewController
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectPayerTableViewCell", for: indexPath) as! SelectPayerTableViewCell_iPad
        let thisPerson = people[indexPath.row]
        cell.thumbnailView.image = thisPerson.thumbnail
        cell.fullNameLabel.text = thisPerson.fullName
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let payingPerson = people[indexPath.row]
        payingPerson.addPaymentsObject(paymentModel.payment)
        paymentModel.payment.payingPerson = payingPerson
        self.presentingViewController!.dismiss(animated: true)
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        people = eventModel.peoplePresentOnEventSortedOnFullName
    }
    
    // MARK: NSObject
}
