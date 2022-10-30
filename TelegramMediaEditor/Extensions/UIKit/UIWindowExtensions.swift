//
//  UIWindowExtensions.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 23.10.22.
//

import UIKit

extension UIWindow {
    
    static var keyWindow: UIWindow? {
        UIApplication.shared.windows.filter { $0.isKeyWindow }.first
    }
}
