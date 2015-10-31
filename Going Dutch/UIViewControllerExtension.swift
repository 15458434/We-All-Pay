//
//  UIViewControllerExtension.swift
//  Bift
//
//  Created by Mark Cornelisse on 20/08/15.
//  Copyright (c) 2015 Over de muur producties. All rights reserved.
//

import UIKit

public extension UIViewController {
    func startResigningFirstResponderOnBackgroundTap() {
        // Make sure a tap in the background dismisses the keyboard as well.
        let thatTickles = UITapGestureRecognizer(target: self, action: "tappedInTheBackground")
        thatTickles.cancelsTouchesInView = true
        view.addGestureRecognizer(thatTickles)
    }
    
    func tappedInTheBackground() {
        let fr = self.view.getFirstResponder()
        fr?.resignFirstResponder()
    }
}