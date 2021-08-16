//
//  NotificationsTableViewController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import UIKit

final class NotificationsTableViewController: UITableViewController {
    @IBOutlet var model: NotificationsModel!
    
    var emptyMessage: MCTableEmptyMessage!
    
    private var notificationsObservation: NSKeyValueObservation!
    
    func setEmptyMessage(for count: Int, with duration: TimeInterval) {
        if count > 0  {
            UIView.animate(withDuration: duration) {
                self.emptyMessage.bigMessage.alpha = 0.0
                self.emptyMessage.borderlineView.alpha = 0.0
                self.tableView.separatorStyle = .singleLine
            }
        } else {
            UIView.animate(withDuration: duration) {
                self.emptyMessage.bigMessage.alpha = 1.0
                self.emptyMessage.borderlineView.alpha = 1.0
                self.tableView.separatorStyle = .none
            }
        }
    }
    
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
        model.updateIsRead(for: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: UIViewController
    
    override func loadView() {
        super.loadView()
        
        emptyMessage = (Bundle.main.loadNibNamed("MCTableEmptyMessage", owner: self, options: nil)!.first as! MCTableEmptyMessage)
        self.tableView.backgroundView = emptyMessage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Notifications", comment: "")
        
        emptyMessage.bigMessage.text = NSLocalizedString("Nothing new right now.", comment: "A message for no notifications in the notifications screen.")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        func createKVO() {
            notificationsObservation = self.observe(\.model.notifications, options: [.initial, .old, .new, .prior], changeHandler: { mySelf, change in
                if change.isPrior {
                    mySelf.tableView.beginUpdates()
                } else {
                    let kind = change.kind
                    let section: Int = 0
                    switch kind {
                    case .setting:
                        mySelf.tableView.beginUpdates()
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
                    mySelf.tableView.endUpdates()
                    mySelf.setEmptyMessage(for: mySelf.model.notifications.count, with: 0.33)
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
