//
//  ZoomTransition.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/24/22.
//

import UIKit

final class PhotoZoomTransition: NSObject, UIViewControllerTransitioningDelegate {
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        PhotoZoomInAnimation()
    }
    
    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        PhotoZoomOutAnimation()
    }
}
