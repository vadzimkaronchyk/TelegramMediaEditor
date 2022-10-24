//
//  PhotoZoomInAnimation.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/24/22.
//

import UIKit

final class PhotoZoomInAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from) as? PhotosViewController,
            let toNavigationController = transitionContext.viewController(forKey: .to) as? UINavigationController,
            let toViewController = toNavigationController.topViewController as? PhotoEditorViewController,
            let fromImageView = fromViewController.transitionImageView(),
            let toImageView = toViewController.transitionImageView()
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        toNavigationController.view.layoutIfNeeded()
        toViewController.view.frame = .zero // workaround to layout subviews properly(considering nav bar)
        
        let containerView = transitionContext.containerView
        
        let photoImageView = UIImageView()
        photoImageView.clipsToBounds = true
        photoImageView.contentMode = fromImageView.contentMode
        photoImageView.image = fromImageView.image
        photoImageView.frame = containerView.convert(fromImageView.frame, from: fromImageView.superview)
        
        containerView.addSubview(toNavigationController.view)
        containerView.addSubview(photoImageView)
        
        let photoDuration = transitionDuration(using: transitionContext)
        let photoAnimator = UIViewPropertyAnimator(
            duration: photoDuration,
            curve: .easeInOut
        ) {
            photoImageView.frame = containerView.convert(toImageView.frame, from: toImageView.superview)
        }
        photoAnimator.addCompletion { position in
            photoImageView.removeFromSuperview()
            transitionContext.completeTransition(position == .end)
        }
        photoAnimator.startAnimation()
        
        toNavigationController.view.alpha = 0
        
        let viewDuration = photoDuration * 0.5
        UIView.animate(
            withDuration: viewDuration,
            delay: photoDuration - viewDuration,
            options: .curveLinear
        ) {
            toNavigationController.view.alpha = 1
        }
    }
}
