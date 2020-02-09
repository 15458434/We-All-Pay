//
//  RemoteConfigEngine.swift
//  We all pay
//
//  Created by Mark Cornelisse on 07/02/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig

@objc(MCRemoteConfigEngine) @objcMembers class RemoteConfigEngine: NSObject {
    @objc(ConfigEngineItem) enum Item: UInt, CaseIterable {
        case percentageOfTimeShowMainBottomBannerOniPhone = 0
        case percentageOfTimeShowPersonViewBannerOniPhone = 1
        case percentageOfTimeShowPaymentViewBannerOniPhone = 2
        case percentageOfTimeShowSolutionViewBannerOniPhone = 3
        case percentageOfTimeShowAfterSolveInterstitialOniPhone = 4
        case percentageOfTimeShowMainBottomBannerOniPad = 5
        case percentageOfTimeShowPaymentViewBannerOniPad = 7
        case percentageOfTimeShowSolutionViewBannerOniPad = 8
        case percentageOfTimeShowAfterSolveInterstitialOniPad = 9
        
        var stringValue: String {
            switch self {
            case .percentageOfTimeShowMainBottomBannerOniPhone:
                return "v1_Percentage_Of_Time_Show_Main_Bottom_Banner_On_iPhone"
            case .percentageOfTimeShowPersonViewBannerOniPhone:
                return "v1_Percentage_Of_Time_Show_Person_View_Banner_On_iPhone"
            case .percentageOfTimeShowPaymentViewBannerOniPhone:
                return "v1_Percentage_Of_Time_Show_Payment_View_Banner_On_iPhone"
            case .percentageOfTimeShowSolutionViewBannerOniPhone:
                return "v1_Percentage_Of_Time_Show_Solution_View_Banner_On_iPhone"
            case .percentageOfTimeShowAfterSolveInterstitialOniPhone:
                return "v1_Percentage_Of_Time_Show_After_Solve_Interstitial_On_iPhone"
            case .percentageOfTimeShowMainBottomBannerOniPad:
                return "v1_Percentage_Of_Time_Show_Main_Bottom_Banner_On_iPad"
            case .percentageOfTimeShowPaymentViewBannerOniPad:
                return "v1_Percentage_Of_Time_Show_Payment_View_Banner_On_iPad"
            case .percentageOfTimeShowSolutionViewBannerOniPad:
                return "v1_Percentage_Of_Time_Show_Solution_View_Banner_On_iPad"
            case .percentageOfTimeShowAfterSolveInterstitialOniPad:
                return "v1_Percentage_Of_Time_Show_After_Solve_Interstitial_On_iPad"
            default:
                fatalError("Value doesn't exist")
            }
        }
    }
    
    private static let remoteConfig = RemoteConfig.remoteConfig()
    
    class func prepareRemoteConfig() {
        var defaults: [String: NSObject] {
            let newValues = RemoteConfigEngine.Item.allCases.reduce([String: NSObject]()) { (dict, item) -> [String: NSObject] in
                var dict = dict
                switch item {
                case .percentageOfTimeShowAfterSolveInterstitialOniPhone, .percentageOfTimeShowAfterSolveInterstitialOniPad:
                    dict[item.stringValue] = 0 as NSNumber
                case .percentageOfTimeShowPaymentViewBannerOniPad, .percentageOfTimeShowSolutionViewBannerOniPad:
                    dict[item.stringValue] = 0 as NSNumber
                default:
                    dict[item.stringValue] = 1 as NSNumber
                }
                return dict
            }
            return newValues
        }
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0
        #endif
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(defaults)
        #if DEBUG
        let expirationDuration: TimeInterval = 0
        #else
        let expirationDuration: TimeInterval = 3600
        #endif
        remoteConfig.fetch(withExpirationDuration: expirationDuration) { (status, error) in
            guard error == nil else {
                debugPrint("An error occured: \(error!)")
                return
            }
            
            remoteConfig.activate { (error) in
                guard error == nil else {
                    debugPrint("Error activating new RemoteConfigSettings: \(error!)")
                    return
                }
                
            }
        }
    }
    
    func config(for item: RemoteConfigEngine.Item) -> NSObject {
        return RemoteConfigEngine.remoteConfig.configValue(forKey: item.stringValue)
    }
    
    // MARK: NSObject
}
