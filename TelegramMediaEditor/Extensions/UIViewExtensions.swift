//
//  UIViewExtensions.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/24/22.
//

import UIKit

extension UIView {
    
    func snapshot(in bounds: CGRect? = nil) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds ?? self.bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
