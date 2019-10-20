//
//  UIViewExtension.swift
//  We all pay
//
//  Created by Mark Cornelisse on 20/08/15.
//  Copyright (c) 2015 Over de muur producties. All rights reserved.
//

import UIKit

public extension UIView {
    @objc func getFirstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }
        for subView in self.subviews {
            if let subviewWhichIsFirstResponder = subView.getFirstResponder() {
                return subviewWhichIsFirstResponder
            }
        }
        return nil
    }
}
