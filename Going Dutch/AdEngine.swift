//
//  AdEngine.swift
//  We all pay
//
//  Created by Mark Cornelisse on 09/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

import UIKit
import AdSupport

import PersonalizedAdConsent
import GoogleMobileAds

@objcMembers class AdEngine: NSObject, GADBannerViewDelegate {
    static let kAdBannerConsent = "7DE9F9CF-B4B9-4DCB-94FC-F0FD62F432DC"
    
    private var putBannerOnScreen: ((_ bannerView: GADBannerView) -> ())?
    private var putBannerOffScreen: ((_ bannerView: GADBannerView) -> ())?
    
    enum EconomicArea {
        case unknown
        case eea
    }
    
    var adUnitID: String?
    
    class func registerDebugDevices() {
        let iPhoneX = "3a960c027f1ea390326793600324a891"
        let iPadRetina = "63f51db641e29b85012042e407de3cba"
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [(kGADSimulatorID as! String), iPhoneX, iPadRetina]
    }
    
    var request: GADRequest {
        let newRequest = GADRequest()
        let kiPhoneX = "3a960c027f1ea390326793600324a891"
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [(kGADSimulatorID as! String), kiPhoneX]
        return newRequest
    }
    
    func prepare(adBanner: GADBannerView, with viewController: UIViewController) {
        func createAdBanner(with consent: PACConsentStatus = .unknown) {
            self.updateSize(for: adBanner, withScreenSize: UIScreen.main.bounds.size)
            adBanner.adUnitID = self.adUnitID!
            adBanner.rootViewController = viewController
            adBanner.delegate = self
            adBanner.load(self.request)
            adBanner.isAutoloadEnabled = true
        }
        
//        func gdprConsentInMobi(economicArea: AdEngine.EconomicArea = .unknown, consentStatus: PACConsentStatus) {
//            var economicAreaString: String {
//                switch economicArea {
//                case .unknown:
//                    return "0"
//                case .eea:
//                    return "1"
//                }
//            }
//            var consentString: String {
//                switch consentStatus {
//                case .personalized:
//                    return "true"
//                default:
//                    return "false"
//                }
//            }
//            
//            if let _ = GADMInMobiConsent.consent {
//                // Nothing todo.
//                return
//            }
//            
//            let consentDictionary: [String: String] = ["gdpr": economicAreaString, IM_GDPR_CONSENT_AVAILABLE: consentString]
//            GADMInMobiConsent.updateGDPRConsent(consentDictionary)
//        }
        
        guard isEnabled else {
            return
        }
        
        PACConsentInformation.sharedInstance.debugGeography = .EEA
        PACConsentInformation.sharedInstance.debugIdentifiers = ["00000000-0000-0000-0000-000000000000", "E0C4F2B0-1AD9-4FEE-B467-7DE63D5E8939"]
        if PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown {
            debugPrint("InEEAorUnknown")
            PACConsentInformation.sharedInstance.requestConsentInfoUpdate(forPublisherIdentifiers: ["pub-5354415674074435"]) { (error) in
                guard error == nil else {
                    debugPrint("Consent info update failed.")
                    return
                }
                
                let ud = UserDefaults.standard
                let consentStatus = PACConsentStatus(rawValue: ud.integer(forKey: AdEngine.kAdBannerConsent))!
                switch consentStatus {
                case .personalized:
//                    gdprConsentInMobi(economicArea: .eea, consentStatus: consentStatus)
                    createAdBanner()
                case .nonPersonalized:
//                    gdprConsentInMobi(economicArea: .eea, consentStatus: consentStatus)
                    createAdBanner()
                default:
                    guard let privacyUrl = URL(string: "https://www.iubenda.com/privacy-policy/7876418"),
                      let form = PACConsentForm(applicationPrivacyPolicyURL: privacyUrl) else {
                        print("incorrect privacy URL.")
                        return
                    }
                    form.shouldOfferPersonalizedAds = true
                    form.shouldOfferNonPersonalizedAds = false
                    form.shouldOfferAdFree = false
                    
                    form.load { [unowned form, unowned viewController] (error) in
                        guard error == nil else {
                            print("error: \(error!)")
                            fatalError("Unable to load consent form.")
                        }
                        
                        form.present(from: viewController) { (error, success) in
                            let consentStatus = PACConsentInformation.sharedInstance.consentStatus
                            UserDefaults.standard.set(consentStatus.rawValue, forKey: AdEngine.kAdBannerConsent)
//                            gdprConsentInMobi(economicArea: .eea, consentStatus: consentStatus)
                            createAdBanner()
                        }
                    }
                }
            }
        } else {
            createAdBanner()
        }
    }
    
    func updateSize(for bannerView: GADBannerView, withScreenSize size: CGSize) {
        guard isEnabled else {
            return
        }
        if size.height > size.width {
            bannerView.adSize = kGADAdSizeSmartBannerPortrait
        } else {
            bannerView.adSize = kGADAdSizeSmartBannerLandscape
        }
    }
    
    var isEnabled: Bool = true
    
    // MARK: GADBannerViewDelegate
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        guard isEnabled else {
            return
        }
        debugPrint("adViewDidReceiveAd: \(String(describing: bannerView.responseInfo?.responseIdentifier)) for \(String(describing: bannerView.responseInfo?.adNetworkClassName))")
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            bannerView.isHidden = false
        }) { (success) in
            
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        guard isEnabled else {
            return
        }
        debugPrint("didFailToReceiveAdWithError: \(error)")
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            bannerView.isHidden = true
        }) { (success) in
            
        }
    }
    
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        
    }
    
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        
    }
    
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        
    }
    
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        
    }
    
    // MARK: NSObject
}
