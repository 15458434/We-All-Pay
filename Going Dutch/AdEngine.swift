//
//  AdEngine.swift
//  We all pay
//
//  Created by Mark Cornelisse on 09/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

import UIKit
import AdSupport

import UserMessagingPlatform

import PersonalizedAdConsent
import GoogleMobileAds
import InMobiAdapter
import AdColonyAdapter
import AppLovinSDK
import MoPub

@objc(MCAdEngine) @objcMembers open class AdEngine: NSObject {
    static let kAdBannerConsent = "7DE9F9CF-B4B9-4DCB-94FC-F0FD62F432DC"
    
    #if SCREENSHOTS
    static var isEnabled: Bool = false
    #else
    static var isEnabled: Bool = true
    #endif
    
    enum ConsentStatus: Int {
        case unknown = 0
        case nonPersonalized = 1
        case personalized = 2
        
        init(consentStatus: PACConsentStatus) {
            switch consentStatus {
            case .nonPersonalized:
                self = .nonPersonalized
            case .personalized:
                self = .personalized
            default:
                self = .unknown
            }
        }
        
        init(consentType: UMPConsentType) {
            switch consentType {
            case .personalized:
                self = .personalized
            case .nonPersonalized:
                self = .nonPersonalized
            default:
                self = .unknown
            }
        }
    }
    
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
    
    private class func gdprConsentInMobi(economicArea: AdEngine.EconomicArea = .unknown, consentStatus: ConsentStatus) {
        var economicAreaString: String {
            switch economicArea {
            case .unknown:
                return "0"
            case .eea:
                return "1"
            }
        }
        var consentString: String {
            switch consentStatus {
            case .personalized:
                return "true"
            default:
                return "false"
            }
        }
        
        if let _ = GADMInMobiConsent.consent {
            // Nothing todo.
            return
        }
        
        let consentDictionary: [String: String] = ["gdpr": economicAreaString, IM_GDPR_CONSENT_AVAILABLE: consentString]
        GADMInMobiConsent.updateGDPRConsent(consentDictionary)
    }
    
    private class func gdprConsentAdcolony(economicArea: AdEngine.EconomicArea = .unknown, consentStatus: ConsentStatus) {
        var gdprRequired: Bool {
            switch economicArea {
            case .unknown:
                return false
            case .eea:
                return true
            }
        }
        var consentString: String {
            switch consentStatus {
            case .personalized:
                return "1"
            default:
                return "0"
            }
        }
        
        let options = GADMediationAdapterAdColony.appOptions!
        options.gdprRequired = gdprRequired
        options.gdprConsentString = consentString
    }
    
    private class func gdprConsentAppLovin(economicArea: AdEngine.EconomicArea = .unknown, consentStatus: ConsentStatus) {
        var gdprRequired: Bool {
            switch economicArea {
            case .unknown:
                return false
            case .eea:
                return true
            }
        }
        var consentValue: Bool {
            switch consentStatus {
            case .personalized:
                return true
            default:
                return false
            }
        }
        
        if gdprRequired {
            ALPrivacySettings.setHasUserConsent(consentValue)
        }
    }
    
    private class func gdprConsentMoPub(economicArea: AdEngine.EconomicArea = .unknown, consentStatus: ConsentStatus) {
        var gdprRequired: Bool {
            switch economicArea {
            case .unknown:
                return false
            case .eea:
                return true
            }
        }
        var consentValue: Bool {
            switch consentStatus {
            case .personalized:
                return true
            default:
                return false
            }
        }
        
        let moPubConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: "b63c7628b51e41c497d6159df9a922b0")
        let moPubInstance = MoPub.sharedInstance()
        moPubInstance.initializeSdk(with: moPubConfig, completion: nil)
        
        if gdprRequired {
            if consentValue {
                moPubInstance.grantConsent()
            } else {
                moPubInstance.revokeConsent()
            }
        }
    }
    
    @objc(presentPrivacyConsentRequestIfNecessaryFromViewController:) class func presentPrivacyConsentRequestIfNecessary(from viewController: UIViewController) {
        
        guard AdEngine.isEnabled else {
            return
        }
        
        guard !MCStoreInterface.defaultStoreInterface.isProProductPurchased else {
            return
        }
        
        PACConsentInformation.sharedInstance.debugGeography = .EEA
        PACConsentInformation.sharedInstance.debugIdentifiers = ["00000000-0000-0000-0000-000000000000", "E0C4F2B0-1AD9-4FEE-B467-7DE63D5E8939"]
        PACConsentInformation.sharedInstance.requestConsentInfoUpdate(forPublisherIdentifiers: ["pub-5354415674074435"]) { (error) in
            guard error == nil else {
                debugPrint("Consent info update failed.")
                return
            }
            
            if PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown {
                debugPrint("InEEAorUnknown")
                
                let userDefaults = UserDefaults.standard
                let storedConsentStatus = PACConsentStatus(rawValue: userDefaults.integer(forKey: AdEngine.kAdBannerConsent))!
                let consentStatus = ConsentStatus(consentStatus: storedConsentStatus)
                switch consentStatus {
                case .personalized:
                    gdprConsentInMobi(economicArea: .eea, consentStatus: consentStatus)
                    gdprConsentAdcolony(economicArea: .eea, consentStatus: consentStatus)
                    gdprConsentAppLovin(economicArea: .eea, consentStatus: consentStatus)
                    gdprConsentMoPub(economicArea: .eea, consentStatus: consentStatus)
                case .nonPersonalized:
                    gdprConsentInMobi(economicArea: .eea, consentStatus: consentStatus)
                    gdprConsentAdcolony(economicArea: .eea, consentStatus: consentStatus)
                    gdprConsentAppLovin(economicArea: .eea, consentStatus: consentStatus)
                    gdprConsentMoPub(economicArea: .eea, consentStatus: consentStatus)
                default:
                    guard let privacyUrl = URL(string: "https://www.iubenda.com/privacy-policy/7876418"),
                          let form = PACConsentForm(applicationPrivacyPolicyURL: privacyUrl) else {
                        print("incorrect privacy URL.")
                        return
                    }
                    form.shouldOfferPersonalizedAds = true
                    form.shouldOfferNonPersonalizedAds = true
                    form.shouldOfferAdFree = false
                    
                    form.load { [unowned form, unowned viewController] (error) in
                        guard error == nil else {
                            print("error: \(error!)")
                            fatalError("Unable to load consent form.")
                        }
                        
                        form.present(from: viewController) { (error, success) in
                            let currentConsentStatus = PACConsentInformation.sharedInstance.consentStatus
                            UserDefaults.standard.set(consentStatus.rawValue, forKey: AdEngine.kAdBannerConsent)
                            let consentStatus = ConsentStatus(consentStatus: currentConsentStatus)
                            gdprConsentInMobi(economicArea: .eea, consentStatus: consentStatus)
                            gdprConsentAdcolony(economicArea: .eea, consentStatus: consentStatus)
                            gdprConsentAppLovin(economicArea: .eea, consentStatus: consentStatus)
                            gdprConsentMoPub(economicArea: .eea, consentStatus: consentStatus)
                        }
                    }
                }
            }
        }
    }
    
    var request: GADRequest {
        let newRequest = DFPRequest()
        return newRequest
    }
    
    // MARK: NSObject
}

#if ADTEST
import GoogleMobileAdsMediationTestSuite

extension AdEngine {
    @objc(presentAdTestSuiteFromPresentingViewController:) class func presentAdTestSuite(from presentingViewController: UIViewController?) {
        guard let presentingViewController = presentingViewController else {
            return
        }
        GoogleMobileAdsMediationTestSuite.present(on:presentingViewController, delegate:nil)
    }
}
#endif
