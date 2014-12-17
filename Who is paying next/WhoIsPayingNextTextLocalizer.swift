//
//  WhoIsPayingNextTextLocalizer.swift
//  We all pay
//
//  Created by Mark Cornelisse on 03/12/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

import UIKit

func createAttributesStringForWhoIsPayingNext(tripName: String, fullNameNextPayer: String) -> NSMutableAttributedString {
    // The code of this function should be replaced to support multiple languages. For now it's just hardcoded.
    let normalFontDescriptor: UIFontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
    let normalFont: UIFont = UIFont(descriptor: normalFontDescriptor, size: 0)
    let normalAttributes: Dictionary = [NSFontAttributeName: normalFont]
    
    let boldFontDescriptor: UIFontDescriptor = normalFontDescriptor.fontDescriptorWithSymbolicTraits(.TraitBold)
    let boldFont: UIFont = UIFont(descriptor: boldFontDescriptor, size: 0)
    let boldAttributes: Dictionary = [NSFontAttributeName: boldFont];
    
    let attributedTripName: NSAttributedString = NSAttributedString(string: tripName, attributes: boldAttributes)
    let attributedFullNameNextPayer: NSAttributedString = NSAttributedString(string: fullNameNextPayer, attributes: boldAttributes)
    
    let firstPartString = String.localizedStringWithFormat(NSLocalizedString("FOR_YOUR_EVENT", comment: "First part of For your event eventName, 'name person' should pay next."))
    let thirdPartString = String.localizedStringWithFormat(NSLocalizedString("SHOULD_PAY_NEXT", comment: "Third part of For your event eventName, 'name person' should pay next."))
    
    let firstPart: NSAttributedString = NSAttributedString(string: firstPartString, attributes: normalAttributes)
    let secondPart: NSAttributedString = NSAttributedString(string: ", ", attributes: normalAttributes)
    let thirdPart: NSAttributedString = NSAttributedString(string: thirdPartString, attributes: normalAttributes)
    
    let finalString: NSMutableAttributedString = NSMutableAttributedString()
    finalString.appendAttributedString(firstPart)
    finalString.appendAttributedString(attributedTripName)
    finalString.appendAttributedString(secondPart)
    finalString.appendAttributedString(attributedFullNameNextPayer)
    finalString.appendAttributedString(thirdPart)
    
    return finalString
}

func betterCreateAttributesStringForWhoIsPayingNext(tripName: String, fullNameNextPayer: String) -> NSMutableAttributedString {
    func createAttributesForFontStyle(style: String, withTrait trait: UIFontDescriptorSymbolicTraits!) -> [NSObject : AnyObject] {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
        if let theTrait = trait {
            let descriptorWithTrait = fontDescriptor.fontDescriptorWithSymbolicTraits(trait)
            let font = UIFont(descriptor: descriptorWithTrait, size: 0)
            return [NSFontAttributeName : font];
        } else {
            let font = UIFont(descriptor: fontDescriptor, size: 0)
            return [NSFontAttributeName : font];
        }
    }
    
    let normalAttributes: Dictionary = createAttributesForFontStyle(UIFontTextStyleBody, withTrait: nil)
    let boldAttributes: Dictionary = createAttributesForFontStyle(UIFontTextStyleBody, withTrait: .TraitBold)
    
    let text = String.localizedStringWithFormat(NSLocalizedString("For your event %@, %@ should pay next", comment: "For your event %1$@, %2$@ should pay next."), tripName, fullNameNextPayer)
    let attributedText = NSMutableAttributedString(string: text, attributes: normalAttributes)
    
//    let replacements = [tripName, fullNameNextPayer]
//    for eachBoldString in replacements {
//        let regularExpression = NSRegularExpression(pattern: tripName, options: nil, error: nil)!
//        regularExpression.enumerateMatchesInString(attributedText.string, options: nil, range: NSMakeRange(0, countElements(attributedText.string)), usingBlock: { (match, flags, stop) -> Void in
//            // apply the style
//            let matchRange = match.rangeAtIndex(1)
//            attributedText.addAttributes(boldAttributes, range: matchRange)
//
//        })
//    }
    
    return attributedText
}

func createErrorMessage() -> NSMutableAttributedString {
    let fontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
    let font = UIFont(descriptor: fontDescriptor, size: 0)
    let text = NSLocalizedString("There is no data to display", comment: "There is no data to display")
    return NSMutableAttributedString(string: text, attributes: [NSFontAttributeName : font])
}