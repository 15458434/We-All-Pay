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
            let title = NSLocalizedString("rate_me_alert_title", value: "Do you like We all pay?", comment: "Question to the user whether or not they like this app.")
            let message = NSLocalizedString("rate_me_alert_message", value: "Please give We all pay a 5 star rating and help other people find the benefits We all pay.", comment: "Message to the user to give We all pay a five star rating.")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let noTitle = NSLocalizedString("rate_me_alert_no", value: "Hell no", comment: "Title of the No button on the rate me in the App Store button.")
            let noAction = UIAlertAction(title: noTitle, style: .cancel, handler: { (action) -> Void in
                rmc.rateMeDisplayed(RateMeControllerAskStatus.no)
                _ = rmc.save()
            })
            alertController.addAction(noAction)
            let yesTitle = NSLocalizedString("rate_me_alert_yes", value: "Sure", comment: "Title of a Yes button on the rate me in the App Store button.")
            let yesAction = UIAlertAction(title: yesTitle, style: .default, handler: { (action) -> Void in
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
