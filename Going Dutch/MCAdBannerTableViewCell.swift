//
//  MCAdBannerTableViewCell.swift
//  We all pay
//
//  Created by Mark Cornelisse on 30/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

import UIKit
import GoogleMobileAds;

@objc(MCAdBannerTableViewCell) final class AdBannerTableViewCell: UITableViewCell {
    private weak var bannerView: GADBannerView?
    
    @objc(updateBannerView:) func update(bannerView: GADBannerView) {
        if let existingBannerView = self.bannerView {
            let constraints = existingBannerView.constraints
            existingBannerView.removeConstraints(constraints)
            existingBannerView.removeFromSuperview()
        }
        self.addSubview(bannerView)
        self.bannerView = bannerView
        self.bannerView!.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        self.bannerView!.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        self.bannerView!.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        self.bannerView!.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.bannerView!.widthAnchor.constraint(equalToConstant: 320).isActive = true
    }
    
    // MARK: UITableViewCell
    
    // MARK: UIView
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
