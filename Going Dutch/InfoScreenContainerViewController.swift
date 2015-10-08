//
//  InfoScreenContainerViewController.swift
//  We all pay
//
//  Created by Mark Cornelisse on 02/10/15.
//  Copyright © 2015 Mark Cornelisse. All rights reserved.
//

import UIKit

class InfoScreenContainerViewController: UIViewController {
    // MARK: IB Outlets
    @IBOutlet var weAllPayVersionLabel: UILabel!
    
    // MARK: New in this class
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch (segue.identifier) {
        case let identifier where identifier == "EmbedInfoScreenViewController_iPad":
            let destination = segue.destinationViewController as! InfoScreenTableViewController
            destination.versionLabel = weAllPayVersionLabel
        default:
            print("Error: segue to nowhere?")
        }
    }
}