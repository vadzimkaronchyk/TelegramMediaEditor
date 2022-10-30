//
//  CanvasView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/24/22.
//

import UIKit

final class CanvasView: UIView {
    
    var drawingColor: UIColor = .white
    
    var lineWidth: Progress {
        get { canvas.lineWidth }
        set { canvas.lineWidth = newValue }
    }
    
    var canUndo: Bool {
        canvas.canUndo
    }
    
    var onUndoChanged: VoidClosure?
    
    private lazy var frozenContext: CGContext = {
        let scale = UIScreen.main.scale
        let boundsSize = bounds.size
        let size = CGSize(
            width: boundsSize.width * scale,
            height: boundsSize.height * scale
        )
        
        let context = CGContext(
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
    
    private let canvas = Canvas()
    
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
        
        if canvas.needsFullRedraw {
            setFrozenImageNeedsUpdate()
            frozenContext.clear(bounds)
            canvas.finishedLines.forEach {
                $0.drawInContext(frozenContext)
            }
            canvas.needsFullRedraw = false
        }
        
        frozenImage = frozenImage ?? frozenContext.makeImage()
        
        if let frozenImage = frozenImage {
            context.draw(frozenImage, in: bounds)
        }
        
        if let activeLine = canvas.activeLine {
            activeLine.drawInContext(context)
        }
    }
    
    private func setFrozenImageNeedsUpdate() {
        frozenImage = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        canvas.rect = bounds
    }
}

private extension CanvasView {

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
        
        switch gestureRecognizer.state {
        case .began:
            let updateRect = canvas.draw(
                atLocation: location,
                velocity: velocity,
                color: drawingColor
            )
            setNeedsDisplay(updateRect)
        case .changed:
            let updateRect = canvas.draw(
                atLocation: location,
                velocity: velocity,
                color: drawingColor
            )
            setNeedsDisplay(updateRect)
        case .ended, .failed, .cancelled:
            var updateRect = canvas.draw(
                atLocation: location,
                velocity: velocity,
                color: drawingColor
            )
            updateRect = updateRect.union(canvas.finishDrawing())
            setNeedsDisplay(updateRect)
            
            onUndoChanged?()
        default:
            break
        }
    }
}

extension CanvasView {
    
    func undo() {
        canvas.undo()
        setNeedsDisplay()
        onUndoChanged?()
    }
    
    func clearAll() {
        canvas.clear()
        setNeedsDisplay()
        onUndoChanged?()
    }
}
