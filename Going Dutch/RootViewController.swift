//
//  RootViewController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/10/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import UIKit

import FirebaseAnalytics

final class RootViewController: UIViewController {
    @IBOutlet var notificationsStateModel: NotificationsInfoModel!
    
    private var infoScreenTransitioner: SideMenuTransitioner?
    
    @IBAction func infoButtonTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "OpenInfoScreenView", sender: self)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AdEngine.presentPrivacyConsentRequestIfNecessary(from: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
        navigationController!.setToolbarHidden(true, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Open Events":
            ()
        case "OpenInfoScreenView":
            let navigationController = segue.destination as! UINavigationController
            navigationController.modalPresentationStyle = .custom
            infoScreenTransitioner = SideMenuTransitioner()
            navigationController.transitioningDelegate = infoScreenTransitioner
            let infoContainerViewController = navigationController.viewControllers.last as! InfoScreenTableViewController
            infoContainerViewController.preferredContentSize = CGSize(width: 320, height: 0);
            infoContainerViewController.notificationEnvironmentModel = notificationsStateModel
        default:
            fatalError("\(segue.identifier!) is an unknown segue.")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - UIResponder
    
    // MARK: - NSObject
}
