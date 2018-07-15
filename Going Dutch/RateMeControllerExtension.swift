//
//  RateMeControllerExtension.swift
//  We all pay
//
//  Created by Mark Cornelisse on 16/02/16.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import Foundation
import RateMeControllerForiOS

extension RateMeController {
    class func openReviewLink() {
        if #available(iOS 11.0, *) {
            let url = URL(string: "itms-apps://itunes.apple.com/app/id642135963?action=write-review")!
            UIApplication.shared.open(url, options: [:]) { (success) in
                guard success else {
                    debugPrint("Unable to open url")
                    return
                }
            }
        } else if #available(iOS 10.0, *) {
            let url = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=642135963&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8")!
            UIApplication.shared.open(url, options: [:]) { (success) in
                guard success else {
                    debugPrint("Unable to open url")
                    return
                }
            }
        } else {
            let url = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=642135963&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8")!
            UIApplication.shared.openURL(url)
        }
    }
}
