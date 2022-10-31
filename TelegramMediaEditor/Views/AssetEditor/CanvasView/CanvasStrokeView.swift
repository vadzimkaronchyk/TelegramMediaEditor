//
//  CanvasStrokeView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/30/22.
//

import UIKit

final class CanvasStrokeView: UIView {
    
    var drawingColor: UIColor = .white
    var lineWidth = Progress.mid
    
    var onDrawingLineFinished: Closure<Line>?
    
    private var clearFrozenContext = false
    private lazy var frozenContext: CGContext = {
        let scale = UIScreen.main.scale
        var size = bounds.size

        size.width *= scale
        size.height *= scale

        let context: CGContext = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!

        context.setLineCap(.round)
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        context.concatenate(transform)

        return context
    }()
    
    private var frozenImage: CGImage?
    
    private(set) var line: Line?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        addPanGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if clearFrozenContext {
            frozenImage = nil
            frozenContext.clear(bounds)
            clearFrozenContext = false
        }
        
        frozenImage = line?.drawInContext(context, frozenContext: frozenContext, bounds: bounds) ?? frozenImage
        
        if let frozenImage = frozenImage {
            context.draw(frozenImage, in: bounds)
        }
    }
}

private extension CanvasStrokeView {
    
    func setupView() {
        backgroundColor = .clear
    }
    
    func addPanGestureRecognizer() {
        addGestureRecognizer(UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePanGesgture)
        ))
    }
    
    @objc func handlePanGesgture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let location = gestureRecognizer.location(in: self)
        let velocity = gestureRecognizer.velocity(in: self)
        
        let line = line ?? .init(color: drawingColor, lineWidth: lineWidth)
        self.line = line
        
        switch gestureRecognizer.state {
        case .began:
            let updateRect = line.draw(
                atLocation: location,
                velocity: velocity,
                color: drawingColor
            )
            setNeedsDisplay(updateRect)
        case .changed:
            let updateRect = line.draw(
                atLocation: location,
                velocity: velocity,
                color: drawingColor
            )
            setNeedsDisplay(updateRect)
        case .ended, .failed, .cancelled:
            let updateRect = line.draw(
                atLocation: location,
                velocity: velocity,
                color: drawingColor
            )
            setNeedsDisplay(updateRect)
            onDrawingLineFinished?(line)
            
            self.line = nil
            clearFrozenContext = true
            setNeedsDisplay()
        default:
            break
        }
    }
}
