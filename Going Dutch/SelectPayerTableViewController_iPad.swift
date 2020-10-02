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

class SelectPayerTableViewController_iPad: UITableViewController, MCTonightsBillTransfer, MCThisPaymentProtocol {
    // MARK: Properties
    var people: [MCPerson]!
    var tonightsBill: MCSharedBill!
    @objc(writableTonightsBill) var writableTonightsBill: MCSharedBill!
    var thisPayment: MCPayment!
    var dismissMe: (()->())?

    // MARK: New in this class
    
    // MARK: Inherited from super
    override func viewDidLoad() {
        super.viewDidLoad()
        
        people = tonightsBill.getArrayOfPeopleSortedOnFullNames()
    }
    
    // MARK: UI Table View Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let payingPerson = people[indexPath.row]
        payingPerson.addPaymentsObject(thisPayment)
        thisPayment.payingPerson = payingPerson
        dismissMe?()
    }
    
    // MARK: UI Table View Data Source
    
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
        cell.fullNameLabel.text = thisPerson.getFullName
        
        return cell
    }
}
