//
//  NotificationsTableViewController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import UIKit

class NotificationsTableViewController: UITableViewController {
    @IBOutlet var model: NotificationsModel!
    
    private var notificationsObservation: NSKeyValueObservation!
    
    // MARK: UITableViewController
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model.notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        return cell
        
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! NotificationTableViewCell
        cell.update(model: model.notifications[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Notifications", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        func createKVO() {
            notificationsObservation = self.observe(\.model.notifications, options: [.old, .new, .prior], changeHandler: { mySelf, change in
                if change.isPrior {
                    self.tableView.beginUpdates()
                } else {
                    let kind = change.kind
                    let section: Int = 0
                    switch kind {
                    case .setting:
                        mySelf.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
                    case .insertion:
                        let indexes = change.indexes!
                        let indexPaths = indexes.map { row in
                            return IndexPath(row: row, section: section)
                        }
                        mySelf.tableView.insertRows(at: indexPaths, with: .automatic)
                    case .removal:
                        let indexes = change.indexes!
                        let indexPaths = indexes.map { row in
                            return IndexPath(row: row, section: section)
                        }
                        mySelf.tableView.deleteRows(at: indexPaths, with: .automatic)
                    case .replacement:
                        ()
                    @unknown default:
                        fatalError("This kind is not available.")
                    }
                    self.tableView.endUpdates()
                }
            })
        }
        
        super.viewWillAppear(animated)
        
        createKVO()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        func destroyKVO() {
            notificationsObservation = nil
        }
        super.viewWillDisappear(animated)
        
        destroyKVO()
    }
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
