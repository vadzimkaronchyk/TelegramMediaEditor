//
//  ColorSliderCursorView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/14/22.
//

import UIKit

final class ColorSliderCursorView: UIView {
    
    var color: HSBColor = .black {
        didSet { setNeedsDisplay() }
    }
    
    var outlineColor: HSBColor = UIColor.secondarySystemBackground.hsbColor {
        didSet { setNeedsDisplay() }
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
        
        let padding = 2.0
        let rectSize = min(rect.height, rect.width)
        let outlineRect = CGRect(
            origin: .single(location: padding),
            size: .square(size: rectSize - 2*padding)
        )
        
        context.saveGState()
        context.setShadow(
            offset: .zero,
            blur: padding,
            color: UIColor.lightGray.cgColor
        )
        context.fillEllipse(in: outlineRect)
        context.restoreGState()
        
        context.setFillColor(outlineColor.cgColor)
        context.fillEllipse(in: outlineRect)
        
        let innerPadding = 3.0
        let innerRect = CGRect(
            origin: .single(location: padding + innerPadding),
            size: .square(size: rectSize - 2*padding - 2*innerPadding)
        )
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: innerRect)
    }
}
