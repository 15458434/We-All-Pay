//
//  SelectCurrencyTableViewController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 04/01/16.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import UIKit
import CoreData

import FirebaseAnalytics

import CurrencyConverter

class SelectCurrencyTableViewController: UITableViewController, UISearchResultsUpdating {
    // MARK: Properties
    var searchController = UISearchController(searchResultsController: nil)
    
    @objc var currencyUpdateModel: CurrencyUpdateModel!
    
    var recentUsedForeignCurrencies: [MCCurrency]!
    
    let collation = UILocalizedIndexedCollation.current()
    var currencies: [Currency]! {
        didSet {
            let nameSelector: Selector = #selector(getter: NSFetchedResultsSectionInfo.name)
            sections = Array(repeating: [], count: collation.sectionTitles.count)
            sortedCurrencies = collation.sortedArray(from: currencies, collationStringSelector: nameSelector) as! [Currency]
            for currency in sortedCurrencies {
                let sectionNumber = collation.section(for: currency, collationStringSelector: nameSelector)
                sections[sectionNumber].append(currency)
            }

            self.tableView.reloadData()
        }
    }
    var sortedCurrencies: [Currency]!
    var sections: [[Currency]]!
    var filteredCurrencies: [Currency]!
    
    var searchActive: Bool {
        if searchController.isActive && searchController.searchBar.text != "" {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Action
    
    @IBAction func mainCancelPressed(_ sender: AnyObject) {
        // Don't select anything just dimiss the currency view controller
        FIRAnalytics.logEvent(withName: "Main Cancel Pressed", parameters: nil)
        navigationController!.presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    // MARK: New in this class
    
    private func filteredContentForSearchText(searchText: String) {
        filteredCurrencies = sortedCurrencies.filter({ (currency) -> Bool in
            return currency.name.lowercased().contains(searchText.lowercased())
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
            searchController.searchBar.searchBarStyle = .prominent
            searchController.searchBar.scopeButtonTitles = []
            searchController.searchBar.showsScopeBar = false
            definesPresentationContext = true
            
            self.extendedLayoutIncludesOpaqueBars = true
            self.edgesForExtendedLayout = UIRectEdge.all
        }
        
        super.viewDidLoad()
        
        prepareCurrencies()
        prepareForSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchController.searchBar.sizeToFit()
        
        self.recentUsedForeignCurrencies = currencyUpdateModel.recentSelectedCurrencies
    }
    
    // MARK: UI Search Results Updating
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    // MARK: NS Fetched Results Controller Delegate
    
    // MARK: MC Dismiss Me Block Protocol
    
    var dismissMe: (()->())?
    
    // MARK: UI Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        func data(indexPath: IndexPath) -> Currency {
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
        
        let thisCellsCurrency = data(indexPath: indexPath)
        FIRAnalytics.logEvent(withName: "didSelectCurrency pressed", parameters: nil)
        
        currencyUpdateModel.updateCurrency(with: thisCellsCurrency.code) { (error) in
            if (error != nil) {
                Swift.debugPrint("Error fetching ExchangeRate: \(error!)")
                
                let title = NSLocalizedString("Unable to fetch exchange rates", comment: "itle message of an alert that pops up when fetching exchange rates is impossibl")
                let message = NSLocalizedString("Fetching exchange rates is not possible at this moment. Check your internet connection and/or hit solve to fetch all missing exchange rates at a later time", comment: "Message explaining what the user can do to refetch exchange rates")
                let dismissTitle = NSLocalizedString("Dismiss", comment: "Title of a button that dismisses an alart")
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: dismissTitle, style: .cancel, handler: nil)
                alertController.addAction(dismissAction)
                
                myPresenter?.present(alertController, animated: true, completion: nil)
            }
        }
        
        if let dismissMe = dismissMe {
            dismissMe()
        } else {
            navigationController!.presentingViewController!.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: UI Table View Data Source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
        return data(section: section)
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var result = collation.sectionIndexTitles
        result.insert(NSLocalizedString("!", comment: "Symbol for recent used currencies"), at: 0)
        return result
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        switch (searchActive, recentUsedForeignCurrencies?.count ?? 0, index) {
        case let (s, rc, i) where s == false && rc > 0 && i == 0:
            return 0
        case let (s, rc, i) where s == false && rc > 0 && i > 0:
            return collation.section(forSectionIndexTitle: index - 1) + 1
        default:
            return collation.section(forSectionIndexTitle: index)
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch (searchActive, recentUsedForeignCurrencies?.count ?? 0) {
        case let (s, _) where s == true:
            debugPrint("numberOfSectionsInTableView: 1")
            return 1
        case let (s, rc) where s == false && rc > 0:
            debugPrint("numberOfSectionsInTableView: \(sections.count + 1)")
            return sections.count + 1
        default:
            debugPrint("numberOfSectionsInTableView: \(sections.count)")
            return sections.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        func data(indexPath: IndexPath) -> Currency {
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

        let cell = tableView.dequeueReusableCell(withIdentifier: "MCSelectCurrencyTableViewCell_iPhone", for: indexPath as IndexPath) as! MCSelectCurrencyTableViewCell_iPhone

        let thisCellsCurrency = data(indexPath: indexPath)
        
        cell.currencyNameLabel.text = thisCellsCurrency.name
        cell.currencySymbolLabel.text = thisCellsCurrency.symbol
        
        if currencyUpdateModel.currencyCode == thisCellsCurrency.code {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        return cell
    }
}

extension SelectCurrencyTableViewController: UISearchBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        if (bar as! UISearchBar == searchController.searchBar) {
            return UIBarPosition.top
        } else {
            return UIBarPosition.any
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        FIRAnalytics.logEvent(withName: "SearchBarDidBeginEditing", parameters: nil)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        FIRAnalytics.logEvent(withName: "SearchBarDidEndEditing", parameters: nil)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        FIRAnalytics.logEvent(withName: "Cancel pressed", parameters: nil)
    }
}

@objc protocol CurrencyUpdateModel {
    var currencyCode: String { get }
    func updateCurrency(with code: String, with completion: @escaping ((_ error: Error?) -> Void))
    var recentSelectedCurrencies: [MCCurrency] { get }
}

class EventUpdateCurrencyModel: NSObject, CurrencyUpdateModel {
    let event: MCSharedBill
    
    @objc init(with event: MCSharedBill) {
        self.event = event
        super.init()
    }
    
    // MARK: CurrencyUpdateModel
    
    var currencyCode: String {
        return self.event.mainCurrency.code
    }
    
    func updateCurrency(with code: String, with completion: @escaping ((Error?) -> Void)) {
        self.event.updateMainCurrency(fromCode: code, withCompletion: completion)
    }
    
    var recentSelectedCurrencies: [MCCurrency] {
        return event.recentUsedForeignCurrencies(5) ?? [MCCurrency]()
    }
}

class PaymentUpdateCurrencyModel: NSObject, CurrencyUpdateModel {
    let payment: MCPayment
    
    @objc init(with payment: MCPayment) {
        self.payment = payment
        super.init()
    }
    
    // MARK: CurrencyUpdateModel
    
    var currencyCode: String {
        return self.payment.currency.code
    }
    
    func updateCurrency(with code: String, with completion: @escaping ((Error?) -> Void)) {
        let mainThreadContext = MCWeAllPayStoreController.defaultStore().mainThreadContext
        let newCurrency = MCCurrency(from: code, from: mainThreadContext)
        let oldCurrency = payment.currency
        payment.currency = newCurrency
        if oldCurrency?.sharedBill.count == 0 && oldCurrency?.payment.count == 0 {
            mainThreadContext?.delete(oldCurrency!)
        }
        
        payment.setNewCurrencyAndAutomaticallyUpdateExchangeRate(newCurrency, withCompletionHandler: completion)
    }
    
    var recentSelectedCurrencies: [MCCurrency] {
        return payment.onWhichBill.recentUsedForeignCurrencies(5) ?? [MCCurrency]()
    }
}
