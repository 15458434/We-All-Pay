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
        } 
    }
}
