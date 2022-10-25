//
//  ColorSpectrumView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/15/22.
//

import UIKit

final class ColorSpectrumView: UIView {
    
    var cornerRadius: Double = 8 {
        didSet { setNeedsDisplay() }
    }
    
    private var colorSize: Double { 2 }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        context.addPath(path.cgPath)
        context.clip()
        
        let width = rect.width
        let height = rect.height
        for x in stride(from: 0.0, to: width, by: colorSize) {
            for y in stride(from: 0.0, to: height, by: colorSize) {
                let hue = y / height
                let (saturation, brightness): (CGFloat, CGFloat) = {
                    let halfWidth = width/2
                    if x < halfWidth {
                        let progress = (halfWidth - x)/halfWidth
                        return (easeInOutSine(x: progress), 1)
                    } else {
                        let progress = (x - halfWidth)/halfWidth
                        return (1, easeInOutSine(x: progress))
                    }
                }()
                let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
                context.setFillColor(color.cgColor)
                context.fill(.init(x: x, y: y, width: colorSize, height: colorSize))
            }
        }
    }
    
    func color(atLocation location: CGPoint) -> HSBColor {
        let x = colorSize * CGFloat(Int(location.x/colorSize))
        let y = colorSize * CGFloat(Int(location.y/colorSize))
        let hue = y/bounds.maxY
        let (saturation, brightness): (CGFloat, CGFloat) = {
            let halfWidth = bounds.width/2
            if x < halfWidth {
                let progress = (halfWidth - x)/halfWidth
                return (easeInOutSine(x: progress), 1)
            } else {
                let progress = (x - halfWidth)/halfWidth
                return (1, easeInOutSine(x: progress))
            }
        }()
        return HSBColor(hue: hue, saturation: saturation, brightness: brightness)
    }
    
    func location(forColor color: HSBColor) -> CGPoint? {
        let saturation = color.saturation
        let brightness = color.brightness
        let halfWidth = bounds.maxX/2
        let y = color.hue * bounds.maxY
        if saturation == 1 {
            return .init(x: halfWidth + halfWidth*reversingEaseInOutSine(x: brightness), y: y)
        } else if brightness == 1 {
            return .init(x: halfWidth - halfWidth*reversingEaseInOutSine(x: saturation), y: y)
        } else {
            return nil
        }
    }
}
