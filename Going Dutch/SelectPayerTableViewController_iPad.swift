//
//  SelectPayerTableViewController_iPad.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/10/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import UIKit
import CoreData

class SelectPayerTableViewController_iPad: UITableViewController, MCTonightsBillTransfer, MCThisPaymentProtocol {
    // MARK: Properties
    var people: [MCPerson]!
    var tonightsBill: MCSharedBill!
    var writeableTonightsBill: MCSharedBill!
    var thisPayment: MCPayment!
    var dismissMe: (()->())?

    // MARK: New in this class
    
    // MARK: Inherited from super
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let unsortedPeople = (Array(tonightsBill.peoplePresent) as! [MCPerson])
        let selector: Selector = "firstName"
        people = UILocalizedIndexedCollation.currentCollation().sortedArrayFromArray(unsortedPeople, collationStringSelector: selector) as! [MCPerson]
    }
    
    // MARK: UI Table View Delegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        thisPayment.payingPerson = people[indexPath.row]
        dismissMe?()
    }
    
    // MARK: UI Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("selectPayerTableViewCell", forIndexPath: indexPath) as! SelectPayerTableViewCell_iPad
        let thisPerson = people[indexPath.row]
        cell.thumbnailView.image = thisPerson.thumbnail
        cell.fullNameLabel.text = thisPerson.getFullName()
        
        return cell
    }
}
