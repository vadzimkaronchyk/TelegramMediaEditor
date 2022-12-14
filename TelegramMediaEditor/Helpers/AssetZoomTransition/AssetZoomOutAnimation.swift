//
//  AssetZoomOutAnimation.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/24/22.
//

import UIKit

final class AssetZoomOutAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromNavigationController = transitionContext.viewController(forKey: .from) as? UINavigationController,
            let fromViewController = fromNavigationController.topViewController as? AssetEditorViewController,
            let toViewController = transitionContext.viewController(forKey: .to) as? AssetsViewController,
            let toImageView = fromViewController.isDrawingSaved ? toViewController.firstAssetImageView : toViewController.selectedAssetImageView
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let fromImageView = fromViewController.drawingImageView
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
