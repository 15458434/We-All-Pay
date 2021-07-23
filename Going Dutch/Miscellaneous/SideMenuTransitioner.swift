//
//  SideMenuTransitioner.swift
//  We all pay
//
//  Created by Mark Cornelisse on 03/10/2019.
//  Copyright © 2019 Mark Cornelisse. All rights reserved.
//

import UIKit

final class SideMenuTransitioner: NSObject, UIViewControllerTransitioningDelegate {
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SideMenuPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SideMenuPresentAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let interactiveDismissableNavigationController = dismissed as! SwipeLeftDissmissableNavigationController
        return SideMenuDismissAnimationController(with: interactiveDismissableNavigationController.dismissInteractionController!)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        let existingAnimator = animator as! SideMenuDismissAnimationController
        guard existingAnimator.interactionController.interactionInProgress else {
            return nil
        }
        return existingAnimator.interactionController
    }
    
    // MARK: NSObject
}

final class SideMenuPresentationController: UIPresentationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    private weak var backgroundTapGestureRecognizer: UITapGestureRecognizer!
    
    @objc private func backgroundTapped(_ sender: UITapGestureRecognizer) {
        guard sender == backgroundTapGestureRecognizer else {
            fatalError("Wrong sender use only with the intended UITapGestureRecognizer")
        }
        
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let transitionCoordinator = navigationController.transitionCoordinator {
            var navigationControllerViewframe = navigationController.view.frame
            navigationControllerViewframe.size.width = viewController.preferredContentSize.width
            
            var viewControllerViewFrame = viewController.view.frame
            viewControllerViewFrame.origin.y = 0
            viewControllerViewFrame.size.width = viewController.preferredContentSize.width
            
            transitionCoordinator.animate(alongsideTransition: { transitionCoordinatorContext in
                navigationController.view!.frame = navigationControllerViewframe
                viewController.view!.frame = viewControllerViewFrame
            }, completion: nil)
            navigationController.viewWillTransition(to: navigationControllerViewframe.size, with: transitionCoordinator)
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        var frame = viewController.view.frame
        frame.size.width = viewController.preferredContentSize.width
        viewController.view.frame = frame
    }
        
    // MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let presentedViewFrame = self.presentedViewController.view.frame
        if presentedViewFrame.contains(gestureRecognizer.location(in: containerView)) {
            return false
        } else {
            return true
        }
    }
    
    // MARK: UIPresentationController
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        if let navigationController = presentedViewController as? UINavigationController {
            navigationController.delegate = self
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var frameOfPresentingViewController = presentingViewController.view.frame
        frameOfPresentingViewController.size.width = 280
        return frameOfPresentingViewController
    }
    
    override func presentationTransitionWillBegin() {
        let backgroundTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        backgroundTapGestureRecognizer.delegate = self
        self.backgroundTapGestureRecognizer = backgroundTapGestureRecognizer
        containerView!.addGestureRecognizer(backgroundTapGestureRecognizer)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        self.presentedViewController.view.clipsToBounds = false
        let presentedLayer = self.presentedViewController.view.layer
        presentedLayer.shadowOpacity = 0.5
        presentedLayer.shadowRadius = 15
        presentedLayer.shadowPath = CGPath(rect: presentedLayer.frame.insetBy(dx: 0, dy: -15), transform: nil)
        presentedLayer.shadowColor = UIColor.black.cgColor
    }
    
    // MARK: NSObject
}

final class SideMenuPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let _ = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from), let toViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }

        let finalFrame: CGRect = transitionContext.finalFrame(for: toViewController)
        let initialFrame: CGRect = CGRect(x: -finalFrame.width, y: CGFloat(0), width: finalFrame.width, height: finalFrame.height)
        toViewController.view.frame = initialFrame
        
        guard let snapshot: UIView = toViewController.view.snapshotView(afterScreenUpdates: true) else {
            return
        }
        
        snapshot.frame = initialFrame
        snapshot.clipsToBounds = false
        snapshot.layer.shadowOpacity = 0.5
        snapshot.layer.shadowRadius = 15
        snapshot.layer.shadowPath = CGPath(rect: snapshot.bounds.insetBy(dx: 0, dy: -15), transform: nil)
        snapshot.layer.shadowColor = UIColor.black.cgColor

        let containerView: UIView = transitionContext.containerView
        containerView.addSubview(toViewController.view)
        containerView.addSubview(snapshot)
        toViewController.view.isHidden = true
        
        let duration: TimeInterval = transitionDuration(using: transitionContext)
        
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

final class SideMenuDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    let interactionController: SideMenuDismissInteractionController
    
    init(with interactionController: SideMenuDismissInteractionController) {
        self.interactionController = interactionController
        super.init()
    }
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from), let snapshot = fromViewController.view.snapshotView(afterScreenUpdates: false) else {
            return
        }
        
        let containerView = transitionContext.containerView
        let initialFrame = fromViewController.view.frame
        let finalFrame = CGRect(x: -initialFrame.size.width, y: 0, width: initialFrame.width, height: initialFrame.height)
        
        snapshot.frame = initialFrame
        snapshot.clipsToBounds = false
        snapshot.layer.shadowOpacity = 0.5
        snapshot.layer.shadowRadius = 15
        snapshot.layer.shadowPath = CGPath(rect: snapshot.bounds.insetBy(dx: 0, dy: -15), transform: nil)
        snapshot.layer.shadowColor = UIColor.black.cgColor
        
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

@objc protocol SideMenuDismissInteractionControllerSource {
    var dismissInteractionController: SideMenuDismissInteractionController? { get }
}

final class SideMenuDismissInteractionController: UIPercentDrivenInteractiveTransition {
    var interactionInProgress: Bool
    
    private var shouldCompleteTransition: Bool
    private weak var viewController: UIViewController!
    
    init(with viewController: UIViewController) {
        interactionInProgress = false
        shouldCompleteTransition = false
        super.init()
        self.viewController = viewController
        prepareGestureRecognizer(in: viewController.view)
    }
    
    private func prepareGestureRecognizer(in view: UIView) {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    private var xTranslationOnBegan: CGFloat?
    private var expectedXTranslationOnEnd: CGFloat?
    private var swipeDistance: CGFloat = 200
    
    @objc private func handleSwipeGesture(_ sender: UIPanGestureRecognizer) {
        func update(xTranslationOnBegan: CGFloat?) {
            if let xTranslationOnBegan = xTranslationOnBegan {
                self.xTranslationOnBegan = xTranslationOnBegan
                self.expectedXTranslationOnEnd = xTranslationOnBegan - swipeDistance
            } else {
                self.xTranslationOnBegan = nil
                self.expectedXTranslationOnEnd = nil
            }
        }
        let translation = sender.location(in: sender.view!)
        var progress = translation.x / swipeDistance
        progress = 1.0 - CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        
        switch sender.state {
        case .began:
            update(xTranslationOnBegan: translation.x)
            interactionInProgress = true
            viewController.dismiss(animated: true, completion: nil)
        case .changed:
            shouldCompleteTransition = progress > 0.4
            self.update(progress)
        case .cancelled:
            update(xTranslationOnBegan: nil)
            interactionInProgress = false
            cancel()
        case .ended:
            update(xTranslationOnBegan: nil)
            interactionInProgress = false
            if shouldCompleteTransition {
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }
}

final class SwipeLeftDissmissableNavigationController: UINavigationController, SideMenuDismissInteractionControllerSource {
    
    // MARK: SideMenuDismissInteractionControllerSource
    
    var dismissInteractionController: SideMenuDismissInteractionController?
    
    // MARK: UINavigationController
    
    // MARK: UIViewController
    
    override func loadView() {
        super.loadView()
        
        self.view.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleHeight]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissInteractionController = SideMenuDismissInteractionController(with: self)
    }
    
    // MARK: UIResponder
    
    // MARK: NSObject
}
