//
//  SelectCurrencyTableViewController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 04/01/16.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import UIKit
import CoreData

import CurrencyConverter

class SelectCurrencyTableViewController: UITableViewController, UISearchResultsUpdating, MCThisPaymentProtocol {
    // MARK: Properties
    var searchController = UISearchController(searchResultsController: nil)
    
    var thisPayment: MCPayment!
    
    let collation = UILocalizedIndexedCollation.currentCollation()
    var currencies: [Currency]! {
        didSet {
            let selector: Selector = "name"
            sections = Array(count: collation.sectionTitles.count, repeatedValue: [])
            sortedCurrencies = collation.sortedArrayFromArray(currencies, collationStringSelector: selector) as! [Currency]
            for currency in sortedCurrencies {
                let sectionNumber = collation.sectionForObject(currency, collationStringSelector: selector)
                sections[sectionNumber].append(currency)
            }

            self.tableView.reloadData()
        }
    }
    var sortedCurrencies: [Currency]!
    var sections: [[Currency]]!
    var filteredCurrencies: [Currency]!
    
    var searchActive: Bool {
        if searchController.active && searchController.searchBar.text != "" {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Action
    
    @IBAction func mainCancelPressed(sender: AnyObject) {
        // Don't select anything just dimiss the currency view controller
        navigationController!.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: New in this class
    
    private func filteredContentForSearchText(searchText: String) {
        filteredCurrencies = sortedCurrencies.filter({ (currency) -> Bool in
            return currency.name.lowercaseString.containsString(searchText.lowercaseString)
        })
        tableView.reloadData()
    }
    
    // MARK: Inherited Froms super
    
    override func viewDidLoad() {
        func prepareCurrencies() {
            currencies = MCWeAllPayStoreController.defaultStore().fetcher.currencyController.currencies
            filteredCurrencies = [Currency]()
        }
        
        func prepareForSearchController() {
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = false
            searchController.hidesNavigationBarDuringPresentation = false
            tableView.tableHeaderView = searchController.searchBar
            searchController.searchBar.delegate = self
            searchController.searchBar.searchBarStyle = .Prominent
            searchController.searchBar.scopeButtonTitles = []
            searchController.searchBar.showsScopeBar = false
            definesPresentationContext = true
            
            self.extendedLayoutIncludesOpaqueBars = true
            self.edgesForExtendedLayout = UIRectEdge.All
        }
        
        super.viewDidLoad()
        
        prepareCurrencies()
        prepareForSearchController()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        searchController.searchBar.sizeToFit()
    }
    
    // MARK: UI Search Results Updating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredContentForSearchText(searchController.searchBar.text!)
    }
    
    // MARK: NS Fetched Results Controller Delegate
    
    // MARK: UI Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let myPresenter = self.presentingViewController
        
        let thisCellsCurrency: Currency
        if searchActive {
            thisCellsCurrency = filteredCurrencies[indexPath.row]
        } else {
            thisCellsCurrency = sections[indexPath.section][indexPath.row]
        }
        
        let mainThreadContext = MCWeAllPayStoreController.defaultStore().mainThreadContext
        let newCurrency = MCCurrency(from: thisCellsCurrency.code, fromContext: mainThreadContext)
        let oldCurrency = thisPayment.currency
        thisPayment.currency = newCurrency
        if oldCurrency.sharedBill.count == 0 && oldCurrency.payment.count == 0 {
            mainThreadContext.deleteObject(oldCurrency)
        }
        
        thisPayment.setNewCurrencyAndAutomaticallyUpdateExchangeRate(newCurrency) { (error) -> Void in
            if (error != nil) {
                Swift.print("Error fetching ExchangeRate: \(error)")
                
                let title = NSLocalizedString("Unable to fetch exchange rates", comment: "itle message of an alert that pops up when fetching exchange rates is impossibl")
                let message = NSLocalizedString("Fetching exchange rates is not possible at this moment. Check your internet connection and/or hit solve to fetch all missing exchange rates at a later time", comment: "Message explaining what the user can do to refetch exchange rates")
                let dismissTitle = NSLocalizedString("Dismiss", comment: "Title of a button that dismisses an alart")
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                let dismissAction = UIAlertAction(title: dismissTitle, style: .Cancel, handler: nil)
                alertController.addAction(dismissAction)
                
                myPresenter?.presentViewController(alertController, animated: true, completion: nil)
            }
            
        }
        
        navigationController!.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UI Table View Data Source
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return collation.sectionTitles[section]
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return collation.sectionIndexTitles
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return collation.sectionForSectionIndexTitleAtIndex(index)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchActive {
            return 1
        } else {
            return sections.count
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filteredCurrencies.count
        } else {
            return sections[section].count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MCSelectCurrencyTableViewCell_iPhone", forIndexPath: indexPath) as! MCSelectCurrencyTableViewCell_iPhone
        
        let thisCellsCurrency: Currency
        if searchActive {
            thisCellsCurrency = filteredCurrencies[indexPath.row]
        } else {
            thisCellsCurrency = sections[indexPath.section][indexPath.row]
        }
        
        cell.currencyNameLabel.text = thisCellsCurrency.name
        cell.currencySymbolLabel.text = thisCellsCurrency.symbol
        
        if thisPayment.currency.code == thisCellsCurrency.code {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
}

extension SelectCurrencyTableViewController: UISearchBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        if (bar as! UISearchBar == searchController.searchBar) {
            return UIBarPosition.Top
        } else {
            return UIBarPosition.Any
        }
    }
}