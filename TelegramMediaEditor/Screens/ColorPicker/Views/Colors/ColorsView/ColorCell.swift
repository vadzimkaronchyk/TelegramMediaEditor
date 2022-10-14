//
//  ColorCell.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 17.10.22.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    
    struct Configuration {
        let color: UIColor
        let isSelected: Bool
    }
    
    var configuration = Configuration(color: .black, isSelected: false) {
        didSet { setNeedsDisplay() }
    }
    
    override var canBecomeFirstResponder: Bool {
        true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if configuration.isSelected {
            let innerRectSize = CGSize.square(size: rect.height*17/30)
            let innerRectOrigin = CGPoint(
                x: (rect.width - innerRectSize.width) / 2,
                y: (rect.height - innerRectSize.height) / 2
            )
            context.setFillColor(configuration.color.cgColor)
            context.fillEllipse(in: .init(origin: innerRectOrigin, size: innerRectSize))
            
            let outlineRectSize = CGSize.square(size: rect.height*27/30)
            let outlineRectOrigin = CGPoint(
                x: (rect.width - outlineRectSize.width) / 2,
                y: (rect.height - outlineRectSize.height) / 2
            )
            context.setStrokeColor(configuration.color.cgColor)
            context.setLineWidth(rect.height*3/30)
            context.strokeEllipse(in: .init(origin: outlineRectOrigin, size: outlineRectSize))
        } else {
            let size = CGSize.square(size: rect.height)
            let origin = CGPoint(
                x: (rect.width - size.width) / 2,
                y: (rect.height - size.height) / 2
            )
            context.setFillColor(configuration.color.cgColor)
            context.fillEllipse(in: .init(origin: origin, size: size))
        }
    }
}
