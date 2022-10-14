//
//  ColorPreviewView.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 17.10.22.
//

import UIKit

final class ColorPreviewView: UIView {
    
    var color: HSBColor = .black {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 10)
        context.addPath(path.cgPath)
        context.clip()
        
        context.setFillColor(.init(gray: 1, alpha: 1))
        context.fill(rect)
        
        context.setFillColor(.init(gray: 0, alpha: 1))
        context.addLines(between: [
            .zero,
            .init(x: rect.width, y: 0),
            .init(x: 0, y: rect.height)
        ])
        context.fillPath()
        
        context.setFillColor(color.cgColor)
        context.fill(rect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
