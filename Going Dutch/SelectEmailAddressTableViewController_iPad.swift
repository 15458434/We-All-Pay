//
//  SelectEmailAddressTableViewController_iPad.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/10/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//


import UIKit

import FirebaseAnalytics

class SelectEmailAddressTableViewController_iPad: UITableViewController, ThisPersonProtocol, MCDismissMeBlockProtocol {
    // MARK: Properties
    var allEmailAddresses: [MCEmailAddress]!
    
    var thisPerson: MCPerson! 
    var dismissMe: (()->())?
    
    var writableThisPerson: MCPerson!
    
    // MARK: Inherited From Super
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let arrayOfEmailAddresses = Array(thisPerson.emailAddress) as! [MCEmailAddress]
        let emailAddressSelector: Selector = #selector(getter: MCPerson.emailAddress)
        allEmailAddresses = UILocalizedIndexedCollation.current().sortedArray(from: arrayOfEmailAddresses, collationStringSelector: emailAddressSelector) as! [MCEmailAddress]
    }
    
    // MARK: UI Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Analytics.logEvent("PickedEmailAddress with picker", parameters: nil)
        let newDefaulEmailAddressObject = allEmailAddresses[(indexPath as NSIndexPath).row]
        thisPerson.setNewDefaultEmailaddressObject(newDefaulEmailAddressObject)
        dismissMe!()
    }
    
    // MARK: UI Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEmailAddresses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MCSelectEmailAddressTableViewCell_iPad", for: indexPath) as! SelectEmailAddressTableViewCell_iPad
        let emailAddress = allEmailAddresses[(indexPath as NSIndexPath).row]
        cell.emailAddressLabel.text = emailAddress.emailAddress
        return cell
    }
}
