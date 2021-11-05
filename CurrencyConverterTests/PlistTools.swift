//
//  PlistTools.swift
//  CurrencyConverterTests
//
//  Created by Mark Cornelisse on 05/11/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import Foundation

func printArrayAsPlist(_ array: [Dictionary<String, Encodable>]) {
    print("************************************** Begin Plist **************************************")
    let plistData = try! PropertyListSerialization.data(fromPropertyList: array, format: .xml, options: 0)
    let text = NSString(data: plistData, encoding: String.Encoding.utf8.rawValue)!
    print(text)
    print("*************************************** End Plist ***************************************")
}
