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
    @objc private var itemModel: AdSectionItemsModel?
    private var adStatusObserver: NSKeyValueObservation?
    
    @objc(updateBannerView:andItemsModel:) func update(bannerView: GADBannerView, itemModel: AdSectionItemsModel) {
        if let existingBannerView = self.bannerView {
            let constraints = existingBannerView.constraints
            existingBannerView.removeConstraints(constraints)
            existingBannerView.removeFromSuperview()
        }
        if self.itemModel != nil {
            self.adStatusObserver = nil
            self.itemModel = nil
        }
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(bannerView)
        self.bannerView = bannerView
        self.bannerView!.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        self.bannerView!.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        self.bannerView!.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        let height: CGFloat = CGFloat(RemoteConfigEngine().number(for: .solutionAdBannerHeight)!.doubleValue)
        self.bannerView!.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.bannerView!.widthAnchor.constraint(equalToConstant: 320).isActive = true
        
        self.itemModel = itemModel
        adStatusObserver = self.observe(\.itemModel!.adStatus, options: [.initial, .new], changeHandler: { mySelf, change in
            switch mySelf.itemModel!.adStatus {
            case .isNotShowing:
                UIView.animate(withDuration: 0.27) {
                    self.bannerView!.alpha = 0.0
                }
            case .isShowing:
                UIView.animate(withDuration: 0.27) {
                    self.bannerView!.alpha = 1.0
                }
            }
        })
    }
    
    // MARK: UITableViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        adStatusObserver = nil
        itemModel = nil
        bannerView = nil
    }
    
    // MARK: UIView
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
