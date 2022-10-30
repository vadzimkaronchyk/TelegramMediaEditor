//
//  UIWindowSceneExtensions.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 23.10.22.
//

import UIKit

extension UIWindowScene {
    
    static var focused: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .first {
                $0.activationState == .foregroundActive && $0 is UIWindowScene
            } as? UIWindowScene
    }
}
