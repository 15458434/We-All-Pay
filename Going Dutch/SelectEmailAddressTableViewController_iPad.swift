//
//  SelectEmailAddressTableViewController_iPad.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/10/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import UIKit

import FirebaseAnalytics

final class SelectEmailAddressTableViewController_iPad: UITableViewController {
    private var model: PersonModel!
    var allEmailAddresses: [MCEmailAddress]!
    
    @objc(updateModel:) func update(model: PersonModel) {
        self.model = model
    }
    
    // MARK: UITableViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let arrayOfEmailAddresses = Array(model.person.emailAddress ?? Set<MCEmailAddress>())
        let emailAddressSelector: Selector = #selector(getter: MCPerson.emailAddress)
        allEmailAddresses = (UILocalizedIndexedCollation.current().sortedArray(from: arrayOfEmailAddresses, collationStringSelector: emailAddressSelector) as! [MCEmailAddress])
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEmailAddresses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MCSelectEmailAddressTableViewCell_iPad", for: indexPath) as! SelectEmailAddressTableViewCell_iPad
        let emailAddress = allEmailAddresses[indexPath.row]
        cell.update(with: emailAddress)
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newDefaulEmailAddressObject = allEmailAddresses[indexPath.row]
        model.update(default: newDefaulEmailAddressObject)
        self.presentingViewController!.dismiss(animated: true)
    }
    
    // MARK: UIViewController
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
