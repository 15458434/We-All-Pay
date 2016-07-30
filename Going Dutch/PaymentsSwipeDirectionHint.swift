//
//  PaymentsSwipeDirectionHint.swift
//  We all pay
//
//  Created by Mark Cornelisse on 11/06/15.
//  Copyright (c) 2015 Mark Cornelisse. All rights reserved.
//

import UIKit

@available(*, deprecated)
@objc class PaymentsSwipeDirectionHintView: UITableViewHeaderFooterView {
    @IBOutlet var hintLabel: UILabel!
    @IBOutlet var horizontalContraintHintLabel: NSLayoutConstraint!
    
    var showHint: Bool = true {
        didSet {
            if showHint {
                hintLabel.alpha = 1.0
                UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.0, options: .CurveEaseIn, animations: { () -> Void in
                    self.horizontalContraintHintLabel.constant = 12.0
                    self.layoutIfNeeded()
                }, completion: nil)
            } else {
                self.horizontalContraintHintLabel.constant = -150.0
                self.layoutIfNeeded()
                hintLabel.alpha = 0.0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let controller = HintsController()
        showHint = controller.showHints
        if !showHint {
            self.horizontalContraintHintLabel.constant = -150.0
        }
    }
}