//
//  NavigationViewController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/10/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCNavigationViewController) final class NavigationViewController: UINavigationController {
    
    // MARK: UINavigationController
    
    // MARK: UIViewController
    
    override func loadView() {
        super.loadView()
        
        if #available(iOS 13, *) {
            let navigationBar = self.navigationBar
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor(named: "navigationBar")
            appearance.titleTextAttributes = [.foregroundColor: UIColor.systemBackground];
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
            navigationBar.isTranslucent = false
        }
    }
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
