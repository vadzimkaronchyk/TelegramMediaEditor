//
//  PhotoZoomInAnimation.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/24/22.
//

import UIKit

final class PhotoZoomInAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.3
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
        toViewController.view.frame = .zero // workaround to layout subviews properly with nav bar
        
        let containerView = transitionContext.containerView
        
        let photoImageView = UIImageView()
        photoImageView.clipsToBounds = true
        photoImageView.contentMode = fromImageView.contentMode
        photoImageView.image = fromImageView.image
        photoImageView.frame = containerView.convert(fromImageView.frame, from: fromImageView.superview)
        
        containerView.addSubview(toNavigationController.view)
        containerView.addSubview(photoImageView)
        
        toNavigationController.view.alpha = 0
        toImageView.alpha = 0
        
        let photoDuration = transitionDuration(using: transitionContext)
        UIView.animateKeyframes(
            withDuration: photoDuration,
            delay: 0,
            animations: {
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 0.6
                ) {
                    photoImageView.frame = containerView.convert(toImageView.frame, from: toImageView.superview)
                }
                UIView.addKeyframe(
                    withRelativeStartTime: 0.2,
                    relativeDuration: 0.4
                ) {
                    toNavigationController.view.alpha = 1
                }
                UIView.addKeyframe(
                    withRelativeStartTime: 0.6,
                    relativeDuration: 0
                ) {
                    toImageView.alpha = 1
                }
                UIView.addKeyframe(
                    withRelativeStartTime: 0.6,
                    relativeDuration: 0.4
                ) {
                    photoImageView.alpha = 0
                }
            },
            completion: { finished in
                photoImageView.removeFromSuperview()
                transitionContext.completeTransition(finished)
            }
        )
    }
}
