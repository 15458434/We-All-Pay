//
//  UIViewControllerRateMeControllerExtension.swift
//  We all pay
//
//  Created by Mark Cornelisse on 16/02/16.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import Foundation
import RateMeControllerForiOS

extension UIViewController {
    func showRateMeIfNecessary() {
        let rmc = RateMeController()
        if rmc.shouldDisplayRateMeQuestion {
            print("Should show.")
            // show rate me alert
            let title = NSLocalizedString("Do you like Freeze?", comment: "Question to the user whether or not they like this app.")
            let message = NSLocalizedString("Please give Freeze a 5 star rating and help other people find Freeze.", comment: "Message to the user to give Freeze a five star rating.")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let noTitle = NSLocalizedString("Hell no", comment: "Title of a No button.")
            let noAction = UIAlertAction(title: noTitle, style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                rmc.rateMeDisplayed(RateMeControllerAskStatus.No)
                rmc.save()
            })
            alertController.addAction(noAction)
            let yesTitle = NSLocalizedString("Sure", comment: "Title of a Yes button.")
            let yesAction = UIAlertAction(title: yesTitle, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                RateMeController.openReviewLink()
                rmc.rateMeDisplayed(RateMeControllerAskStatus.AlreadyRated)
                rmc.save()
            })
            alertController.addAction(yesAction)
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            debugPrint("Should not show.")
            rmc.save()
        }
    }
}
