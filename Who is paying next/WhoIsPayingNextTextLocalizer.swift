//
//  WhoIsPayingNextTextLocalizer.swift
//  We all pay
//
//  Created by Mark Cornelisse on 03/12/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

import UIKit

func betterCreateAttributesStringForWhoIsPayingNext(_ tripName: String, fullNameNextPayer: String) -> NSMutableAttributedString {
    func createAttributesForFontStyle(_ style: String, withTrait trait: UIFontDescriptor.SymbolicTraits) -> [NSAttributedString.Key : Any] {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.body)
        let descriptorWithTrait = fontDescriptor.withSymbolicTraits(trait)
        let font = UIFont(descriptor: descriptorWithTrait!, size: 0)
        if #available(iOS 10, *) {
            return [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.darkText]
        } else {
            return [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.lightText]
        }
    }
    
    let nullTrait: UIFontDescriptor.SymbolicTraits = UIFontDescriptor.SymbolicTraits(rawValue: 0)
    let normalAttributes: Dictionary = createAttributesForFontStyle(UIFont.TextStyle.body.rawValue, withTrait: nullTrait)
//    let boldAttributes: Dictionary = createAttributesForFontStyle(UIFontTextStyleBody, withTrait: .TraitBold)
    
    let text = String.localizedStringWithFormat(NSLocalizedString("For your event %@, %@ should pay next", comment: "For your event %1$@, %2$@ should pay next."), tripName, fullNameNextPayer)
    let attributedText = NSMutableAttributedString(string: text, attributes: normalAttributes)
    
    return attributedText
}

func createErrorMessage() -> NSMutableAttributedString {
    let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.body)
    let font = UIFont(descriptor: fontDescriptor, size: 0)
    let text = NSLocalizedString("There is no data to display", comment: "There is no data to display")
    let attributedResult = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font : font])
    return attributedResult
}
