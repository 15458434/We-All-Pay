//
//  TrueCasino.swift
//  We all pay
//
//  Created by Mark Cornelisse on 08/02/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig

@objc(MCRemoteConfigTrueCasino) @objcMembers class RemoteConfigTrueCasino: NSObject {
    let engine: RemoteConfigEngine
    let item: RemoteConfigEngine.Item
    
    @objc(initWithEngine:andRemoteConfigItem:) init(with engine: RemoteConfigEngine, and remoteConfigItem: RemoteConfigEngine.Item) {
        self.engine = engine
        self.item = remoteConfigItem
        super.init()
    }
    
    var isTrue: Bool {
        guard let item = engine.config(for: self.item) as? RemoteConfigValue else {
            debugPrint("Item is not an RemoteConfigValue: \(engine.config(for: self.item))")
            return false
        }

        let floatValue = item.numberValue.floatValue
        guard floatValue > 0 && floatValue <= 1 else {
            debugPrint("Invalid floatValue: \(floatValue)")
            return false
        }
        let randomValue = Float.random(in: 0...1)
        debugPrint("randomValue: \(randomValue)")
        if randomValue <= floatValue {
            return true
        } else {
            return false
        }
    }
    
    // MARK: NSObject
}
