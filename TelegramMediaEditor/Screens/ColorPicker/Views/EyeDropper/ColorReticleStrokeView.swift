//
//  ColorReticleStrokeView.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 23.10.22.
//

import UIKit

final class ColorReticleStrokeView: UIView {
    
    var color: HSBColor = .black {
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
        
        context.addEllipse(in: rect)
        context.clip()
        
        let size = min(rect.width, rect.height)
        let tileSize = 16.0
        let borderColor: UIColor = color.brightness > 0.9 ? .gray : .white
        
        context.draw(
            .gridImage(
                color: borderColor.cgColor,
                tileSize: Int(tileSize)
            ),
            in: .init(
                origin: .zero,
                size: .square(size: tileSize)
            ),
            byTiling: true
        )
        
        let centerSquareLineWidth = 4.0
        let centerSquarePath = UIBezierPath(
            roundedRect: .init(
                origin: .single(location: (size - tileSize)/2),
                size: .square(size: tileSize)
            ),
            cornerRadius: 2
        ).cgPath
        context.setStrokeColor(borderColor.cgColor)
        context.setLineWidth(centerSquareLineWidth)
        context.addPath(centerSquarePath)
        context.strokePath()
        
        let bottomEllipseWidth = 16.0
        let bottomEllipseRectSize = CGSize.square(size: size - bottomEllipseWidth)
        let bottomEllipseRectOrigin = CGPoint(
            x: (size - bottomEllipseRectSize.width) / 2,
            y: (size - bottomEllipseRectSize.height) / 2
        )
        let bottomEllipseRect = CGRect(
            origin: bottomEllipseRectOrigin,
            size: bottomEllipseRectSize
        )
        context.setStrokeColor(borderColor.cgColor)
        context.setLineWidth(bottomEllipseWidth)
        context.strokeEllipse(in: bottomEllipseRect)

        let topEllipseWidth = 12.0
        let topEllipseRectSize = CGSize.square(size: size - topEllipseWidth)
        let topEllipseRectOrigin = CGPoint(
            x: (size - topEllipseRectSize.width) / 2,
            y: (size - topEllipseRectSize.height) / 2
        )
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(topEllipseWidth)
        context.strokeEllipse(in: .init(
            origin: topEllipseRectOrigin,
            size: topEllipseRectSize
        ))
    }
}

private extension CGImage {
    
    static func gridImage(color: CGColor, tileSize: Int) -> CGImage {
        let context = CGContext(
            data: nil,
            width: tileSize,
            height: tileSize,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        )!
        context.setAllowsAntialiasing(false)
        context.interpolationQuality = .none
        context.setLineWidth(1)
        context.setStrokeColor(color)
        context.move(to: .init(x: tileSize, y: 0))
        context.addLine(to: .zero)
        context.addLine(to: .init(x: 0, y: tileSize))
        context.strokePath()
        
        return context.makeImage()!
    }
}
