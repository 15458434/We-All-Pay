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
        let url = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=642135963&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8")!
        UIApplication.shared.openURL(url)
    }
}
