//
//  NotificationsCountView.swift
//  We all pay
//
//  Created by Mark Cornelisse on 09/07/2021.
//  Copyright © 2021 Mark Cornelisse. All rights reserved.
//

import UIKit

@IBDesignable class NotificationsCountView: UIView {
    @IBInspectable var count: Int = 1 {
        didSet {
            update()
        }
    }
    private var countString: NSAttributedString!
    @IBInspectable var textColor: UIColor = .white {
        didSet {
            update()
        }
    }
    @IBInspectable var fontSize: CGFloat = 17 {
        didSet {
            update()
        }
    }
    
    private func update() {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: fontSize), .foregroundColor: UIColor.white]
        countString = NSAttributedString(string: "\(count)", attributes: attrs)
        self.setNeedsDisplay()
    }
    
    // MARK: UIView
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.masksToBounds = true
        
        var stringRect = self.bounds
        let width = self.bounds.width
        let height = self.bounds.height
        let widthOfTheText = width - (height / 2)
        stringRect.origin.x = (width - widthOfTheText) / 2
        countString.draw(in: stringRect)
    }
    
    override var intrinsicContentSize: CGSize {
        var rect = countString.boundingRect(with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity), options: [], context: nil)
        print("rect: \(rect)")
        rect.origin = CGPoint.zero
        rect.size.width += (rect.size.height / 2)
        return rect.size
    }
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
