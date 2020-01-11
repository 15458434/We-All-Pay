//
//  RootViewController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/10/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import UIKit

import FirebaseAnalytics

class RootViewController: UIViewController {
    // MARK: IBActions
    
    @IBAction func infoButtonTapped(_ sender: AnyObject) {
        Analytics.logEvent("Open Info Screen", parameters: nil)
    }
    
    // MARK: - UIViewController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
        navigationController!.setToolbarHidden(true, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - UIResponder
    
    // MARK: - NSObject
}
