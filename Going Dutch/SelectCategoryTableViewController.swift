

//
//  SelectCategoryTableViewController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 04/01/16.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import UIKit

import FirebaseAnalytics

class SelectCategoryTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, MCDismissMeBlockProtocol {
    @IBOutlet var model: PaymentModel!
    
    var sections: [[CategoryPictureObject]]!
    var categories: [CategoryPictureObject]! {
        didSet {
            let categoryDescriptionSelector: Selector = NSSelectorFromString("categoryDescription")
            let collation = UILocalizedIndexedCollation.current()
            sortedCategories = (collation.sortedArray(from: categories, collationStringSelector: categoryDescriptionSelector) as! [CategoryPictureObject])
            
            self.tableView.reloadData()
        }
    }
    var sortedCategories: [CategoryPictureObject]!
    
    var searchController = UISearchController(searchResultsController: nil)
    var filteredCategories: [CategoryPictureObject]!
    
    @IBAction func mainCancelPressed(_ sender: AnyObject) {
        navigationController!.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc(prepareForUseWithPayment:) func prepareForUse(with payment: MCPayment) {
        self.model.prepareForUse(with: payment)
    }
    
    // MARK: MCDismissMeBlockProtocol
    
    var dismissMe: (()->())?
    
    // MARK: UISearchResultsUpdating
    
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
    
    // MARK: UISearchBarDelegate
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        if (bar as! UISearchBar == searchController.searchBar) {
            return UIBarPosition.top
        } else {
            return UIBarPosition.any
        }
    }
    
    // MARK: UITableViewController
    
    // MARK: UITableViewDelegate
    
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
        
        model.beginUpdates()
        model.update(categoryObject: categoryObject)
        model.endUpdates()
        if dismissMe != nil {
            dismissMe!()
        } else {
            navigationController!.presentingViewController!.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: UITableViewDataSource
    
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
    
    // MARK: UIViewController
    
    override func loadView() {
        super.loadView()
        
        self.navigationItem.title = NSLocalizedString("select_category_view_title", value: "Select category", comment: "The title of the select category screen. It allows for selecting a categoy of the payment.")
    }
    
    override func viewDidLoad() {
        func prepareCategories() {
            categories = CategoryPictureStoreController.shared.pictureObjects
            filteredCategories = [CategoryPictureObject]()
        }
        
        func prepareForSearchController() {
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
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
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
