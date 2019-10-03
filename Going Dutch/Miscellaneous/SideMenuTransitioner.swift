//
//  SideMenuTransitioner.swift
//  We all pay
//
//  Created by Mark Cornelisse on 03/10/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import UIKit

@objcMembers public class SideMenuTransitioner: NSObject, UIViewControllerTransitioningDelegate {
    
    // MARK: UIViewControllerTransitioningDelegate
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SideMenuPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SideMenuPresentAnimationController()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SideMenuDismissAnimationController()
    }
    
    // MARK: NSObject
}

@objcMembers public class SideMenuPresentationController: UIPresentationController {
    
    // MARK: UIPresentationController
    
    public override var frameOfPresentedViewInContainerView: CGRect {
        var frameOfPresentingViewController = presentingViewController.view.frame
        frameOfPresentingViewController.size.width = 280
        return frameOfPresentingViewController
    }
    
    // MARK: NSObject
}

@objcMembers public class SideMenuPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let _ = transitionContext.viewController(forKey: .from), let toViewController = transitionContext.viewController(forKey: .to), let snapshot = toViewController.view.snapshotView(afterScreenUpdates: true) else {
            return
        }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        let initialFrame = CGRect(x: -finalFrame.width, y: 0, width: finalFrame.width, height: finalFrame.height)
        
        snapshot.frame = initialFrame
        snapshot.clipsToBounds = false
        snapshot.layer.shadowOpacity = 0.5
        snapshot.layer.shadowRadius = 15
        snapshot.layer.shadowPath = CGPath(rect: snapshot.bounds.insetBy(dx: 0, dy: -15), transform: nil)
        snapshot.layer.shadowColor = UIColor.black.cgColor
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(snapshot)
        toViewController.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeLinear], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                snapshot.frame = finalFrame
                containerView.backgroundColor = UIColor(white: 0, alpha: 0.3)
            })
        }) { (success) in
            toViewController.view.isHidden = false
            snapshot.removeFromSuperview()
            toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    // MARK: NSObject
}

@objcMembers public class SideMenuDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from), let snapshot = fromViewController.view.snapshotView(afterScreenUpdates: false) else {
            return
        }
        
        let containerView = transitionContext.containerView
        let initialFrame = fromViewController.view.frame
        let finalFrame = CGRect(x: -initialFrame.size.width, y: 0, width: initialFrame.width, height: initialFrame.height)
        
        snapshot.frame = initialFrame
        containerView.addSubview(snapshot)
        fromViewController.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic], animations: {
            snapshot.frame = finalFrame
            containerView.backgroundColor = .clear
        }) { (success) in
            snapshot.removeFromSuperview()
            fromViewController.view.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    // MARK: NSObject
}
