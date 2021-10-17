//
//  RemoteConfigEngine.swift
//  We all pay
//
//  Created by Mark Cornelisse on 07/02/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig

@objc(MCRemoteConfigEngine) @objcMembers final class RemoteConfigEngine: NSObject {
    @objc(ConfigEngineItem) enum Item: UInt, CaseIterable {
        case solutionAdBannerHeight
        
        var stringValue: String {
            switch self {
            case .solutionAdBannerHeight:
                return "v2_solutionView_adBanner_height"
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
                case .solutionAdBannerHeight:
                    dict[item.stringValue] = 50 as NSNumber
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
            
            remoteConfig.activate { success, error in
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
    
    func number(for item: RemoteConfigEngine.Item) -> NSNumber? {
        guard let value = self.config(for: item) as? RemoteConfigValue else {
            debugPrint("key: \(item.stringValue) doesn't exist.")
            return nil
        }
        return value.numberValue
    }
    
    func string(for item: RemoteConfigEngine.Item) -> String? {
        guard let value = self.config(for: item) as? RemoteConfigValue else {
            debugPrint("key: \(item.stringValue) doesn't exist.")
            return nil
        }
        return value.stringValue
    }
    
    func boolean(for item: RemoteConfigEngine.Item) -> Bool {
        guard let value = self.config(for: item) as? RemoteConfigValue else {
            fatalError("key: \(item.stringValue) doesn't exist.")
        }
        return value.boolValue
    }
    
    // MARK: NSObject
}
