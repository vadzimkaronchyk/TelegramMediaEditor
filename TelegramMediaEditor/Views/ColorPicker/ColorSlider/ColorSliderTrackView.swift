//
//  ColorSliderTrackView.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 18.10.22.
//

import UIKit

final class ColorSliderTrackView: UIView {
    
    var colors = (UIColor.clear.cgColor, UIColor.black.cgColor) {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let maskPath = UIBezierPath(
            roundedRect: rect,
            cornerRadius: rect.height/2
        ).cgPath
        context.addPath(maskPath)
        context.clip()
        
        let tileSize = Int(rect.height*2/3)
        context.draw(
            .checkboard(size: tileSize),
            in: .init(
                origin: .zero,
                size: .square(size: tileSize)
            ),
            byTiling: true
        )
        
        context.drawLinearGradient(
            .init(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [colors.0, colors.1] as CFArray,
                locations: [0, 1]
            )!,
            start: .init(x: rect.minX, y: rect.midY),
            end: .init(x: rect.maxX, y: rect.midY),
            options: []
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setNeedsDisplay()
    }
}

private extension CGImage {
    
    static func checkboard(size: Int) -> CGImage {
        let context = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )!
        context.setFillColor(.init(gray: 1, alpha: 1))
        context.fill(.init(origin: .zero, size: .square(size: size)))
        context.setFillColor(.init(gray: 0, alpha: 1))
        let size = Double(size)/2
        context.fill([
            .init(origin: .zero, size: .square(size: size)),
            .init(origin: .single(location: size), size: .square(size: size))
        ])
        return context.makeImage()!
    }
}
