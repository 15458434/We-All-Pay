//
//  SelectEmailAddressTableViewController_iPad.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/10/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import UIKit

class SelectEmailAddressTableViewController_iPad: UITableViewController {
    // MARK: Properties
    var allEmailAddresses: [MCEmailAddress]!
    
    var thisPerson: MCPerson!
    var dismissMe: (()->())?
    
    var writableThisPerson: MCPerson!
    
    // MARK: Inherited From Super
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let arrayOfEmailAddresses = Array(thisPerson.emailAddress) as! [MCEmailAddress]
        allEmailAddresses = UILocalizedIndexedCollation.currentCollation().sortedArrayFromArray(arrayOfEmailAddresses, collationStringSelector: "emailAddress") as! [MCEmailAddress]
    }
    
    // MARK: UI Table View Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let newDefaulEmailAddressObject = allEmailAddresses[indexPath.row]
        thisPerson.setNewDefaultEmailaddressObject(newDefaulEmailAddressObject)
        dismissMe!()
    }
    
    // MARK: UI Table View Data Source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEmailAddresses.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MCSelectEmailAddressTableViewCell_iPad", forIndexPath: indexPath) as! SelectEmailAddressTableViewCell_iPad
        let emailAddress = allEmailAddresses[indexPath.row]
        cell.emailAddressLabel.text = emailAddress.emailAddress
        return cell
    }
}
