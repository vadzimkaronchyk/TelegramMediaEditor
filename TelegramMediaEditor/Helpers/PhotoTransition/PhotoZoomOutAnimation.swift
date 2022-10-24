//
//  PhotoZoomOutAnimation.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/24/22.
//

import UIKit

final class PhotoZoomOutAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromNavigationController = transitionContext.viewController(forKey: .from) as? UINavigationController,
            let fromViewController = fromNavigationController.topViewController as? PhotoEditorViewController,
            let toViewController = transitionContext.viewController(forKey: .to) as? PhotosViewController,
            let fromImageView = fromViewController.transitionImageView(),
            let toImageView = toViewController.transitionImageView()
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        toViewController.view.layoutIfNeeded()
        
        let containerView = transitionContext.containerView
        
        let photoImageView = UIImageView()
        photoImageView.clipsToBounds = true
        photoImageView.contentMode = fromImageView.contentMode
        photoImageView.image = fromImageView.image
        photoImageView.frame = containerView.convert(fromImageView.frame, from: fromImageView.superview)
        
        containerView.addSubview(photoImageView)
        
        let animator = UIViewPropertyAnimator(
            duration: transitionDuration(using: transitionContext),
            curve: .easeInOut
        ) {
            fromNavigationController.view.alpha = 0
            photoImageView.frame = containerView.convert(toImageView.frame, from: toImageView.superview)
        }
        
        animator.addCompletion { position in
            photoImageView.removeFromSuperview()
            transitionContext.completeTransition(position == .end)
        }
        animator.startAnimation()
    }
}
