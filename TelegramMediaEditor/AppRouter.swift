//
//  AppRouter.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/9/22.
//

import UIKit

final class AppRouter {
    
    private let window = UIWindow()
    
    func launch() {
        let viewController = MediaAccessViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        viewController.onAccessGranted = { [weak self] in
            self?.showPhotosScreen()
        }
    }
}

private extension AppRouter {
    
    func showPhotosScreen() {
        let viewController = PhotosViewController()
        window.rootViewController = viewController
    }
}
