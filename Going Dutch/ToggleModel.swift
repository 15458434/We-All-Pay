//
//  ToggleModel.swift
//  We all pay
//
//  Created by Mark Cornelisse on 03/07/2024.
//  Copyright © 2024 Mark Cornelisse. All rights reserved.
//

import Foundation

@objc(MCToggleModel) final class ToggleModel: NSObject {
    @objc dynamic var boolValue: Bool = false
    
    @objc convenience init(boolValue: Bool) {
        self.init()
        self.boolValue = boolValue
    }
    
    @objc func toggle() {
        boolValue.toggle()
    }
}
