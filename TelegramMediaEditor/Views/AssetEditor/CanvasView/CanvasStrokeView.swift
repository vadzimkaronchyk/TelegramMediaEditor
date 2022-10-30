//
//  CanvasStrokeView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/30/22.
//

import UIKit

final class CanvasStrokeView: UIView {
    
    var drawingColor: UIColor = .white
    
    var lineWidth: Progress {
        get { line?.lineWidth ?? .mid }
        set { line?.lineWidth = newValue }
    }
    
    var onDrawingLineFinished: Closure<Line>?
    
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
        guard let context = UIGraphicsGetCurrentContext(), let line = line else { return }
        line.drawInContext(context)
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
        
        let line = line ?? .init(color: drawingColor)
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
        default:
            break
        }
    }
}
