//
//  InterstitialAdEngine.swift
//  We all pay
//
//  Created by Mark Cornelisse on 14/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

import UIKit

import PersonalizedAdConsent
import GoogleMobileAds

@objc(MCInterstitialAdEngineDelegate) protocol InterstitialAdEngineDelegate {
    func willDismissInterstatial(for adEngine: InterstitialAdEngine)
}

@objc(MCInterstitialAdEngine) final class InterstitialAdEngine: AdEngine, GADInterstitialDelegate {
    
    private(set) weak var delegate: InterstitialAdEngineDelegate!
    var shouldShowEngine: RemoteConfigTrueCasino?

    private(set) var interstitialAd: GADInterstitial!
    private(set) weak var viewController: UIViewController!
    private(set) var isOnScreen: Bool = false
    
    @objc(prepareInterstitialwithAdUnitId:andInterstitialAdEngineDelegate:) func prepare(interstitial adUnitID: String, and delegate: InterstitialAdEngineDelegate) {
        func prepareInterstitialAd(with consent: PACConsentStatus = .unknown) {
            self.interstitialAd = GADInterstitial(adUnitID: adUnitID)
            self.interstitialAd.delegate = self
            self.interstitialAd.load(self.request)
        }
        
        guard AdEngine.isEnabled else {
            return
        }
        
        if let shouldShow = self.shouldShowEngine {
            guard shouldShow.isTrue else {
                return
            }
        }
        
        self.delegate = delegate
        
        let consent = PACConsentStatus(rawValue: UserDefaults.standard.integer(forKey: AdEngine.kAdBannerConsent))!
        if (!MCStoreInterface.defaultStoreInterface.isProProductPurchased && (consent == PACConsentStatus.nonPersonalized) || (consent == PACConsentStatus.personalized) || !PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown) {
            prepareInterstitialAd(with: consent)
        }
    }
    
    @objc(putOnScreenIfAvailableWithPresentingViewController:error:) func putOnScreenIfAvailable(with presentingVienController: UIViewController) throws {
        guard self.interstitialAd.isReady else {
            return
        }
        
        self.viewController = presentingVienController
        try self.interstitialAd.canPresent(fromRootViewController: presentingVienController)
        self.interstitialAd.present(fromRootViewController: presentingVienController)
        self.isOnScreen = true
    }
    
    func putOffScreen() {
        if isOnScreen {
            viewController.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: GADInterstitial
    
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
      
    }

    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
      
    }

    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
      
    }

    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        self.delegate.willDismissInterstatial(for: self)
    }

    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      
    }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
      
    }
    
    // MARK: AdEngine
    
    // MARK: NSObject
}
