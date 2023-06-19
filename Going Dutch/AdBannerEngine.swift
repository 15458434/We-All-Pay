//
//  AdBannerEngine.swift
//  We all pay
//
//  Created by Mark Cornelisse on 14/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

import UIKit

import PersonalizedAdConsent
import GoogleMobileAds

@objc(MCAdBannerEngineDelegate) protocol AdBannerEngineDelegate {
    /// Signals the ad banner is ready to be put on the screen.
    /// - Parameters:
    ///   - adEngine: The AdEngine that gave the signal of banner being ready. Supply none if the signal is coming from somewhere else.
    ///   - bannerView: The bannerView that was ready.
    @objc(adEngine:putOnScreenBannerView:) func adEngine(_ adEngine: AdBannerEngine?, putOnscreen bannerView: GADBannerView)
    /// Signals the ad banner has to be removed from the screen.
    /// - Parameters:
    ///   - adEngine: The AdEngine that gave the signal of banner not being ready. Supply non if the signal is coming from somewhere else.
    ///   - bannerView: The bannerVeiw that was not ready.
    @objc(adEngine:putOffScreenBannerView:) func adEngine(_ adEngine: AdBannerEngine?, putOffScreen bannerView: GADBannerView)
}

@objc(MCAdBannerEngine) @objcMembers final class AdBannerEngine: AdEngine, GADBannerViewDelegate {
    
    private(set) var delegate: AdBannerEngineDelegate!
    
    @objc(prepareAdBanner:withAdUnitId:andViewController:) func prepare(adBanner: GADBannerView, with adUnitID: String, and viewController: UIViewController) {
        func prepareAdBanner(with consent: PACConsentStatus = .unknown) {
            self.updateSize(for: adBanner, withScreenSize: UIScreen.main.bounds.size)
            adBanner.adUnitID = adUnitID
            adBanner.rootViewController = viewController
            adBanner.delegate = self
            adBanner.load(self.request)
            adBanner.isAutoloadEnabled = true
        }
        
        guard AdEngine.isEnabled else {
            return
        }
        
        self.delegate = (viewController as! AdBannerEngineDelegate)
        
        let consent = PACConsentStatus(rawValue: UserDefaults.standard.integer(forKey: AdEngine.kAdBannerConsent))!
        if (!MCStoreInterface.defaultStoreInterface.isProProductPurchased && (consent == PACConsentStatus.nonPersonalized) || (consent == PACConsentStatus.personalized) || !PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown) {
            prepareAdBanner(with: consent)
        }
    }
    
    @objc(prepareAdSizeBanner:withAdUnitId:andViewController:) func prepare(adSizeBanner: GADBannerView, with adUnitID: String, and viewController: UIViewController) {
        func prepareAdBanner(with consent: PACConsentStatus = .unknown) {
            adSizeBanner.adSize = GADAdSizeBanner
            adSizeBanner.adUnitID = adUnitID
            adSizeBanner.rootViewController = viewController
            adSizeBanner.delegate = self
            adSizeBanner.load(self.request)
            adSizeBanner.isAutoloadEnabled = true
        }
        
        guard AdEngine.isEnabled else {
            return
        }
        
        self.delegate = (viewController as! AdBannerEngineDelegate)
        
        let consent = PACConsentStatus(rawValue: UserDefaults.standard.integer(forKey: AdEngine.kAdBannerConsent))!
        if (!MCStoreInterface.defaultStoreInterface.isProProductPurchased && (consent == PACConsentStatus.nonPersonalized) || (consent == PACConsentStatus.personalized) || !PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown) {
            prepareAdBanner(with: consent)
        }
    }
    
    @objc(prepareMediumAdBanner:withAdUnitId:andViewController:) func prepare(mediumAdBanner: GADBannerView, with adUnitID: String, and viewController: UIViewController) {
        func prepareAdBanner(with consent: PACConsentStatus = .unknown) {
            mediumAdBanner.adUnitID = adUnitID
            mediumAdBanner.adSize = GADAdSizeMediumRectangle
            mediumAdBanner.rootViewController = viewController
            mediumAdBanner.delegate = self
            mediumAdBanner.load(self.request)
            mediumAdBanner.isAutoloadEnabled = true
        }
        
        guard AdEngine.isEnabled else {
            return
        }
        
        self.delegate = (viewController as! AdBannerEngineDelegate)
        
        let consent = PACConsentStatus(rawValue: UserDefaults.standard.integer(forKey: AdEngine.kAdBannerConsent))!
        if (!MCStoreInterface.defaultStoreInterface.isProProductPurchased && (consent == PACConsentStatus.nonPersonalized) || (consent == PACConsentStatus.personalized) || !PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown) {
            prepareAdBanner(with: consent)
        }
    }
    
    func updateSize(for bannerView: GADBannerView, withScreenSize size: CGSize) {
        guard AdEngine.isEnabled else {
            return
        }
        if size.height > size.width {
            bannerView.adSize = kGADAdSizeSmartBannerPortrait
        } else {
            bannerView.adSize = kGADAdSizeSmartBannerLandscape
        }
    }
    
    private(set) var isReady: Bool = false

    // MARK: GADBannerViewDelegate
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        guard AdEngine.isEnabled else {
            return
        }
        debugPrint("adViewDidReceiveAd: \(String(describing: bannerView.responseInfo?.responseIdentifier)) for \(String(describing: bannerView.responseInfo?.adNetworkClassName))")
        isReady = true
        delegate.adEngine(self, putOnscreen: bannerView)
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        guard AdEngine.isEnabled else {
            return
        }
        debugPrint("didFailToReceiveAdWithError: \(error)")
        isReady = false
        delegate.adEngine(self, putOffScreen: bannerView)
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        
    }
    
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        
    }
    
    // MARK: AdEngine

    // MARK: NSObject
}
