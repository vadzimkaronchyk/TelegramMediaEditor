//
//  ColorPickerSeparatorView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/13/22.
//

import UIKit

final class ColorPickerSeparatorView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.addLines(between: [
            .init(x: rect.minX, y: rect.midY),
            .init(x: rect.maxX, y: rect.midY)
        ])
        context.setLineWidth(1)
        let color = UIColor(red: 0.282, green: 0.282, blue: 0.29, alpha: 1)
        context.setStrokeColor(color.cgColor)
        context.strokePath()
    }
}
