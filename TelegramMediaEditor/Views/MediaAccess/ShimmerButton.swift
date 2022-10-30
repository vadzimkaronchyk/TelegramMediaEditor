//
//  ShimmerButton.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/24/22.
//

import UIKit

class ShimmerButton: UIButton {
    
    private let gradientLayer: CAGradientLayer = {
        let light = UIColor.clear.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.4).cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [light, alpha, light]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0,y: 0.5)
        gradientLayer.locations = [0.35, 0.50, 0.65]
        return gradientLayer
    }()
    
    private let shimmerLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.addSublayer(shimmerLayer)
        shimmerLayer.mask = gradientLayer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimation() {
        let imageView = UIImageView(image: snapshot().withRenderingMode(.alwaysTemplate))
        imageView.tintColor = UIColor(white: 0.9, alpha: 1.0)
        
        let image = imageView.snapshot()
        
        let width = bounds.size.width
        let height = bounds.size.height
        
        shimmerLayer.contents = image.cgImage
        shimmerLayer.frame = bounds
        gradientLayer.frame = CGRect(x: -width, y: 0, width: 3 * width, height: height)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 2
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        gradientLayer.add(animation, forKey: "shimmer")
    }
    
    func stopAnimation() {
        gradientLayer.removeAnimation(forKey: "shimmer")
    }
}
