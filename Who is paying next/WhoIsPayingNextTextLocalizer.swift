//
//  WhoIsPayingNextTextLocalizer.swift
//  We all pay
//
//  Created by Mark Cornelisse on 03/12/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

import UIKit

func createAttributesStringForWhoIsPayingNext(_ tripName: String, fullNameNextPayer: String) -> NSMutableAttributedString {
    // The code of this function should be replaced to support multiple languages. For now it's just hardcoded.
    let normalFontDescriptor: UIFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleBody)
    let normalFont: UIFont = UIFont(descriptor: normalFontDescriptor, size: 0)
    let normalAttributes: Dictionary = [NSFontAttributeName: normalFont]
    
    let boldFontDescriptor: UIFontDescriptor = normalFontDescriptor.withSymbolicTraits(.traitBold)!
    let boldFont: UIFont = UIFont(descriptor: boldFontDescriptor, size: 0)
    let boldAttributes: Dictionary = [NSFontAttributeName: boldFont];
    
    let attributedTripName: AttributedString = AttributedString(string: tripName, attributes: boldAttributes)
    let attributedFullNameNextPayer: AttributedString = AttributedString(string: fullNameNextPayer, attributes: boldAttributes)
    
    let firstPartString = String.localizedStringWithFormat(NSLocalizedString("FOR_YOUR_EVENT", comment: "First part of For your event eventName, 'name person' should pay next."))
    let thirdPartString = String.localizedStringWithFormat(NSLocalizedString("SHOULD_PAY_NEXT", comment: "Third part of For your event eventName, 'name person' should pay next."))
    
    let firstPart: AttributedString = AttributedString(string: firstPartString, attributes: normalAttributes)
    let secondPart: AttributedString = AttributedString(string: ", ", attributes: normalAttributes)
    let thirdPart: AttributedString = AttributedString(string: thirdPartString, attributes: normalAttributes)
    
    let finalString: NSMutableAttributedString = NSMutableAttributedString()
    finalString.append(firstPart)
    finalString.append(attributedTripName)
    finalString.append(secondPart)
    finalString.append(attributedFullNameNextPayer)
    finalString.append(thirdPart)
    
    return finalString
}

//func betterCreateAttributesStringForWhoIsPayingNext(tripName: String, fullNameNextPayer: String) -> NSMutableAttributedString {
//    func createAttributesForFontStyle(style: String, withTrait trait: UIFontDescriptorSymbolicTraits!) -> [NSObject : AnyObject] {
//        let fontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
//        if let theTrait = trait {
//            let descriptorWithTrait = fontDescriptor.fontDescriptorWithSymbolicTraits(trait)!
//            let font = UIFont(descriptor: descriptorWithTrait, size: 0)
//            return [NSFontAttributeName : font];
//        } else {
//            let font = UIFont(descriptor: fontDescriptor, size: 0)
//            return [NSFontAttributeName : font];
//        }
//    }
//    
//    let normalAttributes: Dictionary = createAttributesForFontStyle(UIFontTextStyleBody, withTrait: nil)
//    let boldAttributes: Dictionary = createAttributesForFontStyle(UIFontTextStyleBody, withTrait: .TraitBold)
//    
//    let text = String.localizedStringWithFormat(NSLocalizedString("For your event %@, %@ should pay next", comment: "For your event %1$@, %2$@ should pay next."), tripName, fullNameNextPayer)
//    let attributedText = NSMutableAttributedString(string: text, attributes: normalAttributes)
//    
//    return attributedText
//}

func betterCreateAttributesStringForWhoIsPayingNext(_ tripName: String, fullNameNextPayer: String) -> NSMutableAttributedString {
    func createAttributesForFontStyle(_ style: String, withTrait trait: UIFontDescriptorSymbolicTraits) -> [String : AnyObject] {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleBody)
        let descriptorWithTrait = fontDescriptor.withSymbolicTraits(trait)
        let font = UIFont(descriptor: descriptorWithTrait!, size: 0)
        return [NSFontAttributeName : font];
    }
    
    let nullTrait: UIFontDescriptorSymbolicTraits = UIFontDescriptorSymbolicTraits(rawValue: 0)
    let normalAttributes: Dictionary = createAttributesForFontStyle(UIFontTextStyleBody, withTrait: nullTrait)
//    let boldAttributes: Dictionary = createAttributesForFontStyle(UIFontTextStyleBody, withTrait: .TraitBold)
    
    let text = String.localizedStringWithFormat(NSLocalizedString("For your event %@, %@ should pay next", comment: "For your event %1$@, %2$@ should pay next."), tripName, fullNameNextPayer)
    let attributedText = NSMutableAttributedString(string: text, attributes: normalAttributes)
    
    return attributedText
}

func createErrorMessage() -> NSMutableAttributedString {
    let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyleBody)
    let font = UIFont(descriptor: fontDescriptor, size: 0)
    let text = NSLocalizedString("There is no data to display", comment: "There is no data to display")
    let attributedResult = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName : font])
    return attributedResult
}
