

//
//  SelectCategoryTableViewController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 04/01/16.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import UIKit

import FirebaseAnalytics

class SelectCategoryTableViewController: UITableViewController, MCThisPaymentProtocol, MCDismissMeBlockProtocol {
    // MARK: Properties
    var thisPayment: MCPayment!
    
    var sections: [[CategoryPictureObject]]!
    var categories: [CategoryPictureObject]! {
        didSet {
            let categoryDescriptionSelector: Selector = NSSelectorFromString("categoryDescription")
            let collation = UILocalizedIndexedCollation.current()
            sortedCategories = collation.sortedArray(from: categories, collationStringSelector: categoryDescriptionSelector) as! [CategoryPictureObject]
            
            self.tableView.reloadData()
        }
    }
    var sortedCategories: [CategoryPictureObject]!
    
    var searchController = UISearchController(searchResultsController: nil)
    var filteredCategories: [CategoryPictureObject]!
    
    // MARK: Actions
    
    @IBAction func mainCancelPressed(_ sender: AnyObject) {
        FIRAnalytics.logEvent(withName: "Main Cancel Pressed", parameters: nil)
        navigationController!.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: New in this class
    
    
    // MARK: Inherited From super
    
    override func viewDidLoad() {
        func prepareCategories() {
            categories = CategoryPictureStoreController.sharedController.pictureObjects
            filteredCategories = [CategoryPictureObject]()
        }
        
        func prepareForSearchController() {
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = false
            searchController.hidesNavigationBarDuringPresentation = false
            tableView.tableHeaderView = searchController.searchBar
            searchController.searchBar.delegate = self
            searchController.searchBar.searchBarStyle = .prominent
            searchController.searchBar.scopeButtonTitles = []
            definesPresentationContext = true
            
            self.extendedLayoutIncludesOpaqueBars = true
            self.edgesForExtendedLayout = UIRectEdge.all
        }
        
        super.viewDidLoad()
        
        prepareCategories()
        prepareForSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchController.searchBar.sizeToFit()
    }
    
    // MARK: UI Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let categoryObject: CategoryPictureObject
        if searchController.isActive && (searchController.searchBar.text != "") {
            guard let filteredCategory = filteredCategories?[(indexPath as NSIndexPath).row] else {
                abort()
            }
            categoryObject = filteredCategory
        } else {
            guard let filteredCategory = sortedCategories?[(indexPath as NSIndexPath).row] else {
                abort()
            }
            categoryObject = filteredCategory
        }
        
        FIRAnalytics.logEvent(withName: "didSelecCategory", parameters: ["categoryID": NSNumber.init(value: categoryObject.categoryId)])
        thisPayment.categoryId = NSNumber(value: categoryObject.categoryId)
        if dismissMe != nil {
            dismissMe!()
        } else {
            navigationController!.presentingViewController!.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: UI Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredCategories.count
        } else {
            return sortedCategories.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let category: CategoryPictureObject
        if searchController.isActive && searchController.searchBar.text != "" {
            guard let filteredCategory = filteredCategories?[(indexPath as NSIndexPath).row] else {
                abort()
            }
            category = filteredCategory
        } else {
            guard let filteredCategory = sortedCategories?[(indexPath as NSIndexPath).row] else {
                abort()
            }
            category = filteredCategory
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "selectCategoryCell", for: indexPath) as! MCSelectCategoryTableViewCell_iPhone
        cell.categoryImageView!.image = category.smallPicture
        cell.categoryNameLabel!.text = category.categoryDescription
        
        return cell
    }
    
    // MARK: MC Dismiss Me Block Protocol
    
    var dismissMe: (()->())?
}

extension SelectCategoryTableViewController: UISearchResultsUpdating {
    func filteredContentForSearchText(_ searchText: String) {
        filteredCategories = sortedCategories.filter({ (category) -> Bool in
            return category.categoryDescription.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filteredContentForSearchText(searchBar.text!)
    }
}

extension SelectCategoryTableViewController: UISearchBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        if (bar as! UISearchBar == searchController.searchBar) {
            return UIBarPosition.top
        } else {
            return UIBarPosition.any
        }
    }
}
