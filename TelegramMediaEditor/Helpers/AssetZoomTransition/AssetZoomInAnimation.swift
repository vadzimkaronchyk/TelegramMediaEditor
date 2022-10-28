//
//  AssetZoomInAnimation.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/24/22.
//

import UIKit

final class AssetZoomInAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from) as? AssetsViewController,
            let toNavigationController = transitionContext.viewController(forKey: .to) as? UINavigationController,
            let toViewController = toNavigationController.topViewController as? AssetEditorViewController,
            let fromImageView = fromViewController.selectedAssetImageView
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        toNavigationController.view.layoutIfNeeded()
        toViewController.view.frame = .zero // workaround to layout subviews properly with nav bar
        
        let toImageView = toViewController.drawingImageView
        let containerView = transitionContext.containerView
        
        let assetImageView = UIImageView()
        assetImageView.clipsToBounds = true
        assetImageView.contentMode = fromImageView.contentMode
        assetImageView.image = fromImageView.image
        assetImageView.frame = containerView.convert(fromImageView.frame, from: fromImageView.superview)
        
        containerView.addSubview(toNavigationController.view)
        containerView.addSubview(assetImageView)
        
        toNavigationController.view.alpha = 0
        toImageView.alpha = 0
        
        UIView.animateKeyframes(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            animations: {
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 0.6
                ) {
                    assetImageView.frame = containerView.convert(toImageView.frame, from: toImageView.superview)
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
                    assetImageView.alpha = 0
                }
            },
            completion: { finished in
                assetImageView.removeFromSuperview()
                transitionContext.completeTransition(finished)
            }
        )
    }
}
