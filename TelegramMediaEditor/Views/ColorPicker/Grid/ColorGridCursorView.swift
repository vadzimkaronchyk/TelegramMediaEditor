//
//  ColorGridCursorView.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 22.10.22.
//

import UIKit

final class ColorGridCursorView: UIView {
    
    var lineWidth = 3.0 {
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
        
        context.addPath(UIBezierPath(
            roundedRect: rect.inset(by: .init(
                top: lineWidth/2,
                left: lineWidth/2,
                bottom: lineWidth/2,
                right: lineWidth/2
            )),
            cornerRadius: 8
        ).cgPath)
        context.setLineWidth(lineWidth)
        context.setStrokeColor(UIColor.white.cgColor)
        context.strokePath()
    }
}
