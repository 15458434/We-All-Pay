//
//  WhoIsPayingNextTextLocalizer.swift
//  We all pay
//
//  Created by Mark Cornelisse on 03/12/14.
//  Copyright (c) 2014 Mark Cornelisse. All rights reserved.
//

import UIKit

func createAttributesStringForWhoIsPayingNext(tripName: String, fullNameNextPayer: String) -> NSMutableAttributedString {
    let normalFontDescriptor: UIFontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
    let normalFont: UIFont = UIFont(descriptor: normalFontDescriptor, size: 0)
    let normalAttributes: Dictionary = [NSFontAttributeName: normalFont]
    
    let boldFontDescriptor: UIFontDescriptor = normalFontDescriptor.fontDescriptorWithSymbolicTraits(.TraitBold)
    let boldFont: UIFont = UIFont(descriptor: boldFontDescriptor, size: 0)
    let boldAttributes: Dictionary = [NSFontAttributeName: boldFont];
    
    let attributedTripName: NSAttributedString = NSAttributedString(string: tripName, attributes: boldAttributes)
    let attributedFullNameNextPayer: NSAttributedString = NSAttributedString(string: fullNameNextPayer, attributes: boldAttributes)
    
    let firstPart: NSAttributedString = NSAttributedString(string: "For your event ", attributes: normalAttributes)
    let secondPart: NSAttributedString = NSAttributedString(string: ", ", attributes: normalAttributes)
    let thirdPart: NSAttributedString = NSAttributedString(string: " should pay next.", attributes: normalAttributes)
    
    let finalString: NSMutableAttributedString = NSMutableAttributedString()
    finalString.appendAttributedString(firstPart)
    finalString.appendAttributedString(attributedTripName)
    finalString.appendAttributedString(secondPart)
    finalString.appendAttributedString(attributedFullNameNextPayer)
    finalString.appendAttributedString(thirdPart)
    
    return finalString
}