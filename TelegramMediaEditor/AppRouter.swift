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
        let viewController = PhotosViewController()
        viewController.onAccessRestricted = { [weak self] in
            self?.showMediaAccessScreen()
        }
        viewController.onPhotoSelected = { [weak self] asset in
            self?.showPhotoEditorScreen(asset: asset)
        }
        window.rootViewController = viewController
    }
    
    func showPhotoEditorScreen(asset: PHAsset) {
        let viewController = PhotoEditorViewController(asset: asset)
        viewController.onClose = { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .overFullScreen
        window.rootViewController?.present(navigationController, animated: true)
    }
}
