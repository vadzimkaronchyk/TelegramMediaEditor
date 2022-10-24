//
//  UIViewExtensions.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/24/22.
//

import UIKit

extension UIView {
    
    var snapshot: UIImage? {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        
        let image = renderer.image { context in
            layer.render(in: context.cgContext)
        }
        
        return image
    }
}
