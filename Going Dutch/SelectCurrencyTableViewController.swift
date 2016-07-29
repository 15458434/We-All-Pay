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
    
    var recentUsedForeignCurrencies: [MCCurrency]!
    
    let collation = UILocalizedIndexedCollation.currentCollation()
    var currencies: [Currency]! {
        didSet {
            let nameSelector: Selector = Selector("name")
            sections = Array(count: collation.sectionTitles.count, repeatedValue: [])
            sortedCurrencies = collation.sortedArrayFromArray(currencies, collationStringSelector: nameSelector) as! [Currency]
            for currency in sortedCurrencies {
                let sectionNumber = collation.sectionForObject(currency, collationStringSelector: nameSelector)
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
            if #available(iOS 9.0, *) {
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
            } else {
                searchController.searchResultsUpdater = self
                searchController.dimsBackgroundDuringPresentation = false
                searchController.hidesNavigationBarDuringPresentation = false
                searchController.searchBar.sizeToFit()
                tableView.tableHeaderView = searchController.searchBar
                searchController.searchBar.delegate = self
                searchController.searchBar.searchBarStyle = .Prominent
                searchController.searchBar.scopeButtonTitles = []
                searchController.searchBar.showsScopeBar = false
                definesPresentationContext = true
                
                self.extendedLayoutIncludesOpaqueBars = true
                self.edgesForExtendedLayout = UIRectEdge.All
            }
        }
        
        super.viewDidLoad()
        
        prepareCurrencies()
        prepareForSearchController()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        searchController.searchBar.sizeToFit()
        
        self.recentUsedForeignCurrencies = thisPayment!.onWhichBill.recentUsedForeignCurrencies() ?? [MCCurrency]()
    }
    
    // MARK: UI Search Results Updating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredContentForSearchText(searchController.searchBar.text!)
    }
    
    // MARK: NS Fetched Results Controller Delegate
    
    // MARK: MC Dismiss Me Block Protocol
    
    var dismissMe: (()->())?
    
    // MARK: UI Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        func data(indexPath: NSIndexPath) -> Currency {
            debugPrint("didSelectRowAtIndexPath: \(indexPath)")
            switch (searchActive, recentUsedForeignCurrencies?.count ?? 0, indexPath.section) {
            case let (searchActive, _, _) where searchActive == true:
                return filteredCurrencies[indexPath.row];
            case let (searchActive, rc, section) where searchActive == false && rc > 0 && section == 0:
                let result = recentUsedForeignCurrencies[indexPath.row]
                return Currency(name: result.name, code: result.code)
            case let (searchActive, rc, section) where searchActive == false && rc > 0 && section > 0:
                return sections[section - 1][indexPath.row]
            default:
                return sections[indexPath.section][indexPath.row]
            }
        }
        let myPresenter = self.presentingViewController
        
        let thisCellsCurrency = data(indexPath)
        
        let mainThreadContext = MCWeAllPayStoreController.defaultStore().mainThreadContext
        let newCurrency = MCCurrency(from: thisCellsCurrency.code, fromContext: mainThreadContext)
        let oldCurrency = thisPayment.currency
        thisPayment.currency = newCurrency
        if oldCurrency.sharedBill.count == 0 && oldCurrency.payment.count == 0 {
            mainThreadContext.deleteObject(oldCurrency)
        }
        
        thisPayment.setNewCurrencyAndAutomaticallyUpdateExchangeRate(newCurrency) { (error) -> Void in
            if (error != nil) {
                Swift.debugPrint("Error fetching ExchangeRate: \(error)")
                
                let title = NSLocalizedString("Unable to fetch exchange rates", comment: "itle message of an alert that pops up when fetching exchange rates is impossibl")
                let message = NSLocalizedString("Fetching exchange rates is not possible at this moment. Check your internet connection and/or hit solve to fetch all missing exchange rates at a later time", comment: "Message explaining what the user can do to refetch exchange rates")
                let dismissTitle = NSLocalizedString("Dismiss", comment: "Title of a button that dismisses an alart")
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                let dismissAction = UIAlertAction(title: dismissTitle, style: .Cancel, handler: nil)
                alertController.addAction(dismissAction)
                
                myPresenter?.presentViewController(alertController, animated: true, completion: nil)
            }
            
        }
        
        if let dismissMe = dismissMe {
            dismissMe()
        } else {
            navigationController!.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: UI Table View Data Source
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        func data(section: Int) -> String {
            switch (searchActive, recentUsedForeignCurrencies?.count ?? 0, section) {
            case let (searchActive, rc, section) where searchActive == false && rc > 0 && section == 0:
                return NSLocalizedString("Recent", comment: "Message to the user that this section in the tableview contains recently used foreign currencies")
            case let (searchActive, rc, section) where searchActive == false && rc > 0 && section > 0:
                return collation.sectionTitles[section - 1]
            default:
                return collation.sectionTitles[section]
            }
        }
        return data(section)
    }

    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var result = collation.sectionIndexTitles
        result.insert(NSLocalizedString("!", comment: "Symbol for recent used currencies"), atIndex: 0)
        return result
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        switch (searchActive, recentUsedForeignCurrencies?.count ?? 0, index) {
        case let (s, rc, i) where s == false && rc > 0 && i == 0:
            return 0
        case let (s, rc, i) where s == false && rc > 0 && i > 0:
            return collation.sectionForSectionIndexTitleAtIndex(index - 1) + 1
        default:
            return collation.sectionForSectionIndexTitleAtIndex(index)
        }
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        switch (searchActive, recentUsedForeignCurrencies?.count ?? 0) {
        case let (s, _) where s == true:
            return 1
        case let (s, rc) where s == false && rc > 0:
            return sections.count + 1
        default:
            return sections.count
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (searchActive, recentUsedForeignCurrencies?.count ?? 0, section) {
        case let (searchActive, _, _) where searchActive == true:
            return filteredCurrencies.count
        case let (searchActive, rc, section) where searchActive == false && rc > 0 && section == 0:
            return recentUsedForeignCurrencies.count
        case let (searchActive, rc, section) where searchActive == false && rc > 0 && section > 0:
            return sections[section - 1].count
        default:
            return sections[section].count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        func data(indexPath: NSIndexPath) -> Currency {
            switch (searchActive, recentUsedForeignCurrencies?.count ?? 0, indexPath.section) {
            case let (searchActive, _, _) where searchActive == true:
                return filteredCurrencies[indexPath.row];
            case let (searchActive, rc, section) where searchActive == false && rc > 0 && section == 0:
                let result = recentUsedForeignCurrencies[indexPath.row]
                return Currency(name: result.name, code: result.code)
            case let (searchActive, rc, section) where searchActive == false && rc > 0 && section > 0:
                return sections[section - 1][indexPath.row]
            default:
                return sections[indexPath.section][indexPath.row]
            }
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("MCSelectCurrencyTableViewCell_iPhone", forIndexPath: indexPath) as! MCSelectCurrencyTableViewCell_iPhone

        let thisCellsCurrency = data(indexPath)
        
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