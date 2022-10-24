//
//  ColorsCircleView.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 22.10.22.
//

import UIKit

final class ColorsCircleView: UIView {

    private let gradientLayer = CAGradientLayer()
    private let maskLayer = CAShapeLayer()
    
    var color: HSBColor = .black {
        didSet { setNeedsDisplay() }
    }
    
    private var gradientWidth: Double { 3 }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        gradientLayer.type = .conic
        gradientLayer.colors = [
            HSBColor(hue: 60/360, saturation: 0.69, brightness: 0.89).cgColor,
            HSBColor(hue: 29/360, saturation: 0.7, brightness: 0.91).cgColor,
            HSBColor(hue: 0, saturation: 0.7, brightness: 0.9).cgColor,
            HSBColor(hue: 298/360, saturation: 0.62, brightness: 0.76).cgColor,
            HSBColor(hue: 247/360, saturation: 0.61, brightness: 0.91).cgColor,
            HSBColor(hue: 190/360, saturation: 0.65, brightness: 0.88).cgColor,
            HSBColor(hue: 143/360, saturation: 0.67, brightness: 0.91).cgColor,
            HSBColor(hue: 96/360, saturation: 0.7, brightness: 0.9).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        layer.addSublayer(gradientLayer)
        
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.lineWidth = gradientWidth
        gradientLayer.mask = maskLayer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let rectSize = min(rect.height, rect.width)
        let innerRectSize = CGSize.square(size: rectSize*19/33)
        let innerRectOrigin = CGPoint(
            x: (rectSize - innerRectSize.width) / 2,
            y: (rectSize - innerRectSize.height) / 2
        )
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: .init(origin: innerRectOrigin, size: innerRectSize))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        let maskPath = UIBezierPath(ovalIn: bounds.inset(by: .init(
            top: gradientWidth/2,
            left: gradientWidth/2,
            bottom: gradientWidth/2,
            right: gradientWidth/2
        )))
        maskLayer.path = maskPath.cgPath
    }
}
