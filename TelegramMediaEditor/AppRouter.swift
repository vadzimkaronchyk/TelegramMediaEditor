//
//  AppRouter.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/9/22.
//

import UIKit
import Photos

final class AppRouter {
    
    private let window = AppWindow()
    
    func launch() {
        window.makeKeyAndVisible()
        showMediaAccessScreen()
    }
}

private extension AppRouter {
    
    func showMediaAccessScreen() {
        let viewController = MediaAccessViewController()
        viewController.onAccessGranted = { [weak self] in
            self?.showPhotosScreen()
        }
        window.rootViewController = viewController
    }
    
    func showPhotosScreen() {
        let transition = CATransition()
        transition.type = .reveal
        transition.subtype = .fromBottom
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: .easeIn)
        window.layer.add(transition, forKey: kCATransition)
        
        let viewController = PhotosViewController()
        viewController.onAccessRestricted = { [weak self] in
            self?.showMediaAccessScreen()
        }
        viewController.onPhotoSelected = { [weak self] in
            self?.showPhotoEditorScreen(
                fromViewController: viewController,
                withTransition: $0.0,
                asset: $0.1
            )
        }
        window.rootViewController = viewController
    }
    
    func showPhotoEditorScreen(
        fromViewController: PhotosViewController,
        withTransition transition: PhotoZoomTransition,
        asset: PHAsset
    ) {
        let viewController = PhotoEditorViewController(asset: asset)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.standardAppearance = {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            return appearance
        }()
        navigationController.transitioningDelegate = transition
        navigationController.modalPresentationStyle = .custom
        
        fromViewController.present(navigationController, animated: true)
    }
}
