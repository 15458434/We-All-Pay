//
//  RootViewController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 05/10/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    // MARK: Inherited From Super
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
        navigationController!.setToolbarHidden(true, animated: true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
}
