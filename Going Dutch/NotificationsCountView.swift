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
    private var countStringRect: CGRect = .zero
    
    private func update() {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: fontSize), .foregroundColor: UIColor.white]
        countString = NSAttributedString(string: "\(count)", attributes: attrs)
        countStringRect = countString.boundingRect(with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity), options: [], context: nil)
        self.setNeedsDisplay()
    }
    
    // MARK: UIView
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.masksToBounds = true
        
        var stringRect = countStringRect
        stringRect.origin.x = self.bounds.midX - (countStringRect.size.width / 2)
        stringRect.origin.y = self.bounds.midY - (countStringRect.size.height / 2)
        // fix draw position
        countString.draw(in: stringRect)
    }
    
    override var intrinsicContentSize: CGSize {
        var rect = countStringRect
        rect.origin = CGPoint.zero
        let halfHeight = (rect.size.height / 2)
        if halfHeight > rect.size.width {
            rect.size.width = rect.size.height
        } else {
            rect.size.width += halfHeight
        }
        return rect.size
    }
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
