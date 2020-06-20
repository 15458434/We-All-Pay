//
//  ScrollViewAdjusterToKeyboard.swift
//  We all pay
//
//  Created by Mark Cornelisse on 27/01/2020.
//  Copyright © 2020 Mark Cornelisse. All rights reserved.
//

import UIKit

@objc(MCScrollViewAdjusterToKeyboard) final class ScrollViewAdjusterToKeyboard: NSObject {
    private(set) var scrollView: UIScrollView!
    private(set) var textFields: [UITextField]!
    
    private var activeTextField: UITextField? {
        let activeTextFields = textFields.filter { (textField) -> Bool in
            return textField.isFirstResponder
        }
        return activeTextFields.first
    }
    
    @objc(prepareForUseWithScrollView:andTextFields:) func prepareForUse(with scrollView: UIScrollView, and textFields: [UITextField]) {
        self.scrollView = scrollView
        self.textFields = textFields
    }
    
    @objc func start() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillUpdate(_:)), name: UITextField.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UITextField.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillUpdate(_:)), name: UITextField.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc private func keyboardWillUpdate(_ notification: Notification) {
        guard let activeTextField = self.activeTextField else {
            return
        }
        let userInfo = notification.userInfo!
        let endRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let animationCurve = UIView.AnimationOptions(rawValue: userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt)
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        adjustscrollViewToKeyboard(for: activeTextField, with: endRect.height, and: duration, and: animationCurve)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let activeTextField = activeTextField else {
            return
        }
        let userInfo = notification.userInfo!
        let animationCurve = UIView.AnimationOptions(rawValue: userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt)
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        adjustscrollViewToKeyboard(for: activeTextField, with: 0, and: duration, and: animationCurve)
    }
    
    private func adjustscrollViewToKeyboard(for textField: UITextField, with bottomInset: CGFloat, and duration: TimeInterval, and animationCurve: UIView.AnimationOptions) {
        UIView.animate(withDuration: duration, delay: 0.0, options: animationCurve, animations: {
            // code to modify
            var contentInset = self.scrollView.contentInset
            contentInset.bottom = bottomInset
            self.scrollView.contentInset = contentInset
            self.scrollView.scrollRectToVisible(textField.frame, animated: false)
        }, completion: nil)
    }
    
    @objc func stop() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: NObject
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
