//
//  SelectCategoryTableViewController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 04/01/16.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import UIKit

class SelectCategoryTableViewController: UITableViewController, MCThisPaymentProtocol, MCDismissMeBlockProtocol {
    // MARK: Properties
    var thisPayment: MCPayment!
    
    var sections: [[CategoryPictureObject]]!
    var categories: [CategoryPictureObject]! {
        didSet {
            let selector: Selector = "categoryDescription"
            let collation = UILocalizedIndexedCollation.currentCollation()
            sortedCategories = collation.sortedArrayFromArray(categories, collationStringSelector: selector) as! [CategoryPictureObject]
            
            self.tableView.reloadData()
        }
    }
    var sortedCategories: [CategoryPictureObject]!
    
    var searchController = UISearchController(searchResultsController: nil)
    var filteredCategories: [CategoryPictureObject]!
    
    // MARK: Actions
    
    @IBAction func mainCancelPressed(sender: AnyObject) {
        navigationController!.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
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
            searchController.searchBar.searchBarStyle = .Prominent
            searchController.searchBar.scopeButtonTitles = []
            definesPresentationContext = true
            
            self.extendedLayoutIncludesOpaqueBars = true
            self.edgesForExtendedLayout = UIRectEdge.All
        }
        
        super.viewDidLoad()
        
        prepareCategories()
        prepareForSearchController()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        searchController.searchBar.sizeToFit()
    }
    
    // MARK: UI Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let categoryObject: CategoryPictureObject
        if searchController.active && (searchController.searchBar.text != "") {
            guard let filteredCategory = filteredCategories?[indexPath.row] else {
                abort()
            }
            categoryObject = filteredCategory
        } else {
            guard let filteredCategory = sortedCategories?[indexPath.row] else {
                abort()
            }
            categoryObject = filteredCategory
        }
        
        thisPayment.categoryId = NSNumber(short: categoryObject.categoryId)
        if dismissMe != nil {
            dismissMe!()
        } else {
            navigationController!.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: UI Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredCategories.count
        } else {
            return sortedCategories.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let category: CategoryPictureObject
        if searchController.active && searchController.searchBar.text != "" {
            guard let filteredCategory = filteredCategories?[indexPath.row] else {
                abort()
            }
            category = filteredCategory
        } else {
            guard let filteredCategory = sortedCategories?[indexPath.row] else {
                abort()
            }
            category = filteredCategory
        }

        let cell = tableView.dequeueReusableCellWithIdentifier("selectCategoryCell", forIndexPath: indexPath) as! MCSelectCategoryTableViewCell_iPhone
        cell.categoryImageView!.image = category.smallPicture
        cell.categoryNameLabel!.text = category.categoryDescription
        
        return cell
    }
    
    // MARK: MC Dismiss Me Block Protocol
    
    var dismissMe: (()->())?
}

extension SelectCategoryTableViewController: UISearchResultsUpdating {
    func filteredContentForSearchText(searchText: String) {
        filteredCategories = sortedCategories.filter({ (category) -> Bool in
            return category.categoryDescription.lowercaseString.containsString(searchText.lowercaseString)
        })
        tableView.reloadData()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filteredContentForSearchText(searchBar.text!)
    }
}

extension SelectCategoryTableViewController: UISearchBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        if (bar as! UISearchBar == searchController.searchBar) {
            return UIBarPosition.Top
        } else {
            return UIBarPosition.Any
        }
    }
}