//
//  CircleView.swift
//  We all pay
//
//  Created by Mark Cornelisse on 14/09/2016.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import UIKit

@IBDesignable final public class CircularImageView: UIImageView {
    // MARK: UIImageView
    
    // MARK: UIView
    
    override public func layoutSubviews() {
        super.layoutSubviews()

        let mask = CAShapeLayer()
        mask.path = UIBezierPath(ovalIn: self.bounds).cgPath
        self.layer.mask = mask
    }
    
    // MARK: UIResponder
    
    // MARK: NSObject
    
    #if TARGET_INTERFACE_BUILDER
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        let environment = ProcessInfo.processInfo.environment
        let projectSourceDirectories : String = environment["IB_PROJECT_SOURCE_DIRECTORIES"]!
        let directories = projectSourceDirectories.components(separatedBy: ":")
        
        if directories.count != 0 {
            let firstPath = directories[0]
            let imagePath = (firstPath as NSString).appendingPathComponent("Going Dutch/circularPictureInCodeDemo.png")
            
            let image = UIImage(contentsOfFile: imagePath)
            self.image = image
        }
        
    }
    #endif
}

