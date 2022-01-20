//
//  main.swift
//  acpm
//
//  Created by Mark Cornelisse on 20/01/2022.
//  Copyright © 2022 Mark Cornelisse. All rights reserved.
//

import Foundation

var sourceUrl: URL!
var destinationURL: URL!

guard CommandLine.arguments.count >= 3 else {
    CommandLine.arguments.enumerated().forEach { element in
        print("element: \(element)")
    }
    fatalError("Not enough arguments. Please add a source and destination plist file.")
}

CommandLine.arguments.enumerated().forEach { element in
    if element.offset > 0 {
        if sourceUrl == nil {
            let sourcePath = element.element
            sourceUrl = URL(fileURLWithPath: sourcePath)
            return
        } else if destinationURL == nil {
            let destinationPath = element.element
            destinationURL = URL(fileURLWithPath: destinationPath)
            return
        }
    }
}

let sourceData = try! Data(contentsOf: sourceUrl)
let sourceArray = try! PropertyListSerialization.propertyList(from: sourceData, options: [], format: nil) as! NSArray
let destinationArray = sourceArray.map { sourceItem -> CurrencyItem in
    let item = CurrencyItem()
    item.setValuesForKeys(sourceItem as! [String : Any])
    let currencyLocale = Locale(identifier: "es")
    let currencyName = (currencyLocale as NSLocale).displayName(forKey: NSLocale.Key.currencyCode, value: item.code!)
    if let currencyName = currencyName {
        item.name = currencyName
    }
    return item
}.map { currencyItem -> [String: Any] in
    var newDictionary = [String: Any]()
    newDictionary["name"] = currencyItem.name! as NSString
    newDictionary["type"] = currencyItem.type!
    newDictionary["code"] = currencyItem.code! as NSString
    return newDictionary
}

let destinationData = try! PropertyListSerialization.data(fromPropertyList: destinationArray, format: .xml, options: 0)
try! destinationData.write(to: destinationURL)

print("Bazinga")
