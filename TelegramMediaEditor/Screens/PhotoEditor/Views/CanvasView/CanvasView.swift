//
//  CanvasView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/24/22.
//

import UIKit

final class CanvasView: UIView {
    
    var drawingColor: UIColor = .white {
        didSet { setNeedsDisplay() }
    }
    
    var canUndo: Bool {
        !previousLines.isEmpty
    }
    
    var onUndoChanged: VoidClosure?
    
    private var velocities = [CGFloat]()
    private var currentLine: Line?
    private var previousLines = [Line]()
    
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
        
        var lines = previousLines
        if let currentLine = currentLine {
            lines.append(currentLine)
        }
        lines.forEach { $0.drawInContext(context) }
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
        let position = gestureRecognizer.location(in: self)
        let lineWidth = extractLineSize(from: gestureRecognizer)
        let linePoint = LinePoint(position: position, width: lineWidth)
        
        switch gestureRecognizer.state {
        case .began:
            currentLine = .init(color: drawingColor, point: linePoint)
        case .changed:
            guard let currentLine = currentLine else { return }
            currentLine.appendPoint(linePoint)
            setNeedsDisplay()
        case .ended, .failed, .cancelled:
            guard let currentLine = currentLine else { return }
            
            currentLine.appendPoint(linePoint)
            previousLines.append(currentLine)
            self.currentLine = nil
            velocities.removeAll()
            setNeedsDisplay()
            
            onUndoChanged?()
        default:
            break
        }
    }
    
    
    func extractLineSize(from panGestureRecognizer: UIPanGestureRecognizer) -> CGFloat {
        let velocity = (panGestureRecognizer.velocity(in: panGestureRecognizer.view)).length
        var size = (velocity / 166).clamped(minValue: 1, maxValue: 40)
        
        if !velocities.isEmpty {
            size = size*0.2 + velocities[velocities.count-1]*0.8;
        }
        
        velocities.append(size)
        return size
    }
}

extension CanvasView {
    
    func undo() {
        previousLines.removeLast()
        // TODO: calcualte rect
        setNeedsDisplay()
        onUndoChanged?()
    }
    
    func clearAll() {
        currentLine = nil
        previousLines.removeAll()
        setNeedsDisplay()
        onUndoChanged?()
    }
}
