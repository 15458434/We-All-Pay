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
            let title = NSLocalizedString("Do you like We all pay?", comment: "Question to the user whether or not they like this app.")
            let message = NSLocalizedString("Please give We all pay a 5 star rating and help other people find the benefits We all pay.", comment: "Message to the user to give We all pay a five star rating.")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let noTitle = NSLocalizedString("Hell no", comment: "Title of a No button.")
            let noAction = UIAlertAction(title: noTitle, style: UIAlertAction.Style.cancel, handler: { (action) -> Void in
                rmc.rateMeDisplayed(RateMeControllerAskStatus.no)
                _ = rmc.save()
            })
            alertController.addAction(noAction)
            let yesTitle = NSLocalizedString("Sure", comment: "Title of a Yes button.")
            let yesAction = UIAlertAction(title: yesTitle, style: UIAlertAction.Style.default, handler: { (action) -> Void in
                RateMeController.openReviewLink()
                rmc.rateMeDisplayed(RateMeControllerAskStatus.alreadyRated)
                _ = rmc.save()
            })
            alertController.addAction(yesAction)
            present(alertController, animated: true, completion: nil)
        } else {
            debugPrint("Should not show.")
            _ = rmc.save()
        }
    }
}
