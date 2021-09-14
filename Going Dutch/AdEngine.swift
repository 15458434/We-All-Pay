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
import FBAudienceNetwork

struct TCFReader {
    /// Function that extracts from whether or not gdpr applies.
    /// - Returns: True if gdpr applies
    func gdprApplies() -> Bool {
        return UserDefaults.standard.integer(forKey: "IABTCF_gdprApplies") == 1
    }

    /// Check if a binary string has a "1" at position "index"
    /// - Parameters:
    ///   - input: inputString
    ///   - index: index of the attribute
    /// - Returns: True if the binary has a "1" at position "index" (1-based)
    private func hasAttribute(input: String, index: Int) -> Bool {
        return input.count >= index && String(Array(input)[index - 1]) == "1"
    }

    /// Check if consent is given for a list of purposes
    /// - Parameters:
    ///   - purposes: Array of purposes
    ///   - purposeConsent: consent string
    ///   - hasVendorConsent:
    /// - Returns: True if consent has ben given.
    fileprivate func hasConsentFor(purposes: [Int], purposeConsent: String, hasVendorConsent: Bool) -> Bool {
        return purposes.allSatisfy { hasAttribute(input: purposeConsent, index: $0) } && hasVendorConsent
    }

    // Check if a vendor either has consent or legitimate interest for a list of purposes
    /// check if there's consent or legitimate interest for purposes
    /// - Parameters:
    ///   - purposes: Array of purposes
    ///   - purposeConsent:
    ///   - purposeLI:
    ///   - hasVendorConsent:
    ///   - hasVendorLI:
    /// - Returns: true of there's consent or legitimate interest for the purposes
    private func hasConsentOrLegitimateInterestFor(purposes: [Int], purposeConsent: String, purposeLI: String, hasVendorConsent: Bool, hasVendorLI: Bool) -> Bool {
        return purposes.allSatisfy { (hasAttribute(input: purposeLI, index: $0) && hasVendorLI) || (hasAttribute(input: purposeConsent, index: $0) && hasVendorConsent) }
    }

    fileprivate func canShowAds() -> Bool {
        let purposeConsent = UserDefaults.standard.string(forKey: "IABTCF_PurposeConsents") ?? ""
        let vendorConsent = UserDefaults.standard.string(forKey: "IABTCF_VendorConsents") ?? ""
        let vendorLI = UserDefaults.standard.string(forKey: "IABTCF_VendorLegitimateInterests") ?? ""
        let purposeLI = UserDefaults.standard.string(forKey: "IABTCF_PurposeLegitimateInterests") ?? ""
        
        let googleId = 755
        let hasGoogleVendorConsent = hasAttribute(input: vendorConsent, index: googleId)
        let hasGoogleVendorLI = hasAttribute(input: vendorLI, index: googleId)
        
        // Minimum required for at least non-personalized ads
        return hasConsentFor(purposes: [1], purposeConsent: purposeConsent, hasVendorConsent: hasGoogleVendorConsent) && hasConsentOrLegitimateInterestFor(purposes: [2,7,9,10], purposeConsent: purposeConsent, purposeLI: purposeLI, hasVendorConsent: hasGoogleVendorConsent, hasVendorLI: hasGoogleVendorLI)
    }
    
    /// Permission to show personalizedAds
    /// - Returns: True if personalizedAds can be shown.
    fileprivate func canShowPersonalizedAds() -> Bool {
        // required for personalized ads
        let purposeConsent = UserDefaults.standard.string(forKey: "IABTCF_PurposeConsents") ?? ""
        let vendorConsent = UserDefaults.standard.string(forKey: "IABTCF_VendorConsents") ?? ""
        let vendorLI = UserDefaults.standard.string(forKey: "IABTCF_VendorLegitimateInterests") ?? ""
        let purposeLI = UserDefaults.standard.string(forKey: "IABTCF_PurposeLegitimateInterests") ?? ""
        
        let googleId = 755
        let hasGoogleVendorConsent = hasAttribute(input: vendorConsent, index: googleId)
        let hasGoogleVendorLI = hasAttribute(input: vendorLI, index: googleId)
        
        let canShowPersonalizedAds = hasConsentFor(purposes: [1,3,4], purposeConsent: purposeConsent, hasVendorConsent: hasGoogleVendorConsent) && hasConsentOrLegitimateInterestFor(purposes: [2,7,9,10], purposeConsent: purposeConsent, purposeLI: purposeLI, hasVendorConsent: hasGoogleVendorConsent, hasVendorLI: hasGoogleVendorLI)
        debugPrint("canShowPersonalizedAds: \(canShowPersonalizedAds)")
        return canShowPersonalizedAds
    }
}

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
        func printUserDefaults() {
            debugPrint("********************************************************** UserDefaults.standard begin **********************************************************\n")
            let string = NSString(format: "%@", UserDefaults.standard.dictionaryRepresentation())
            debugPrint(string)
            debugPrint("*********************************************************** UserDefaults.standard end ***********************************************************\n")
        }
        
        func launchAdSystem() {
            GADMobileAds.sharedInstance().start { status in
                debugPrint("consentStatus: \(status.adapterStatusesByClassName)")
                // Facebook
                if #available(iOS 14.0, *) {
                    FBAdSettings.setAdvertiserTrackingEnabled(ATTrackingManager.trackingAuthorizationStatus == .authorized)
                }

                // GDPR
                let tcf = TCFReader()
                if tcf.gdprApplies() {
                    let canShowPersonalizedAds = tcf.canShowPersonalizedAds()
                    // AppLovin
                    ALPrivacySettings.setHasUserConsent(tcf.canShowPersonalizedAds())
                    // Mopub
                    if canShowPersonalizedAds {
                        MoPub.sharedInstance().grantConsent()
                    } else {
                        MoPub.sharedInstance().revokeConsent()
                    }
                }
            }
        }
        
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
                                    printUserDefaults()
                                    launchAdSystem()
                                }
                            })
                        } else {
                            // Keep the form available for changes to user consent.
                        }
                    })
                }
            default:
                // App can start requesting ads.
                printUserDefaults()
                launchAdSystem()
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
