//
//  AdEngine.swift
//  We all pay
//
//  Created by Mark Cornelisse on 09/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

import UIKit
import AdSupport
import AppTrackingTransparency

import UserMessagingPlatform

import PersonalizedAdConsent
import GoogleMobileAds
import AppLovinSDK
import MoPubSDK

@objc(MCAdEngine) @objcMembers open class AdEngine: NSObject {
    // TODO: Remove on 14-08-2022
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
    }
    
    enum EconomicArea {
        case unknown
        case eea
    }
    
    var adUnitID: String?
    
    class func registerDebugDevices() {
        let iPhoneX = "23915c03dc297a967b28ed1458c0f269"
        let iPadRetina = "63f51db641e29b85012042e407de3cba"
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [kGADSimulatorID, iPhoneX, iPadRetina]
    }
    
    @objc(presentPrivacyConsentRequestIfNecessaryFromViewController:) class func presentPrivacyConsentRequestIfNecessary(from viewController: UIViewController) {
        debugPrint("My IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
        guard AdEngine.isEnabled else {
            return
        }
        
        guard !MCStoreInterface.defaultStoreInterface.isProProductPurchased else {
            return
        }
        
        // clean up old stuff if it exists.
        if UserDefaults.standard.integer(forKey: kAdBannerConsent) > 0 {
            UserDefaults.standard.removeObject(forKey: kAdBannerConsent)
            PACConsentInformation.sharedInstance.reset()
        }
        
        // Create a UMPRequestParameters object.
        let parameters = UMPRequestParameters()
        // Set tag for under age of consent. Here false means users are not under age.
        parameters.tagForUnderAgeOfConsent = false
        
        let debugSettings = UMPDebugSettings()
        debugSettings.testDeviceIdentifiers = ["00000000-0000-0000-0000-000000000000", "E0C4F2B0-1AD9-4FEE-B467-7DE63D5E8939", "73A44587-F726-466C-BB61-E090FC096D70", "B54D6D4B-66D7-47EF-A24C-53152802D822"]
        debugSettings.geography = .disabled
        parameters.debugSettings = debugSettings
        
        // Request an update to the consent information.
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters, completionHandler: { error in
            guard error == nil else {
                // Handle the error.
                debugPrint("UMPConsentInformation.sharedInstance.requestConsentInfoUpdate error: \(error!)")
                return
            }
            
            // The consent information state was updated.
            // You are now ready to check if a form is available.
            switch UMPConsentInformation.sharedInstance.consentStatus {
            case .required:
                let formStatus = UMPConsentInformation.sharedInstance.formStatus
                if formStatus == UMPFormStatus.available {
                    UMPConsentForm.load(completionHandler: { form, loadError in
                        guard loadError == nil else {
                            // Handle the error
                            debugPrint("UMPConsentForm.loadError: \(loadError!)")
                            return
                        }
                        
                        // Present the form. You can also hold on to the reference to present
                        // later.
                        if UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatus.required {
                            form?.present(from: viewController, completionHandler: { dismissError in
                                guard dismissError == nil else {
                                    debugPrint("form dismissed error: \(dismissError!)")
                                    return
                                }
                                
                                if UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatus.obtained {
                                    
                                    GADMobileAds.sharedInstance().start(completionHandler: nil)
                                    ALPrivacySettings.setHasUserConsent(true)
                                    if MoPub.sharedInstance().isGDPRApplicable == .yes {
                                        MoPub.sharedInstance().grantConsent()
                                    }
                                }
                            })
                        } else {
                            // Keep the form available for changes to user consent.
                        }
                    })
                }
            default:
                GADMobileAds.sharedInstance().start(completionHandler: nil)
                ALPrivacySettings.setHasUserConsent(true)
                if MoPub.sharedInstance().isGDPRApplicable == .yes {
                    MoPub.sharedInstance().grantConsent()
                }
                // App can start requesting ads.
                GADMobileAds.sharedInstance().start { status in
                    debugPrint("consentStatus: \(status.adapterStatusesByClassName)")
                }
            }
        })
    }
    
    var request: GADRequest {
        let newRequest = GADRequest()
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
