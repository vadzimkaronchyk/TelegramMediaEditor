//
//  CircleTextControlView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/31/22.
//

import UIKit

final class CircleTextControlView: UIView {
    
    var color = UIColor.white {
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
        
        let lineWidth = 2.0
        let size = min(rect.width, rect.height)
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(lineWidth)
        context.strokeEllipse(in: .init(
            origin: .single(location: lineWidth/2),
            size: .square(size: size - lineWidth)
        ))
        context.strokePath()
    }
}
