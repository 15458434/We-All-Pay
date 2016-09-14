//
//  CircleView.swift
//  We all pay
//
//  Created by Mark Cornelisse on 14/09/2016.
//  Copyright © 2016 Mark Cornelisse. All rights reserved.
//

import UIKit

@IBDesignable class CirclularImageView: UIImageView {
    // MARK: UIImageView
    
    // MARK: UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let height = self.frame.height / 2.0
        let width = self.frame.width / 2.0
        self.layer.cornerRadius = min(height, width)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        let processInfo = ProcessInfo.processInfo
        let environment = processInfo.environment
        let projectSourceDirectories : AnyObject = environment["IB_PROJECT_SOURCE_DIRECTORIES"]! as AnyObject
        let directories = projectSourceDirectories.components(separatedBy: ":")
        
        if directories.count != 0 {
            let firstPath = directories[0]
            let imagePath = (firstPath as NSString).appendingPathComponent("Going Dutch/circularPictureInCodeDemo.png")
            
            let image = UIImage(contentsOfFile: imagePath)
            self.image = image
        }
        
    }
}

