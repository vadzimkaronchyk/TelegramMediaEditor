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
    
    private var currentLine: Line?
    private var previousLines = [Line]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        var lines = previousLines
        if let currentLine = currentLine {
            lines.append(currentLine)
        }
        for line in lines {
            line.color.setStroke()
            line.path.stroke()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        
        let point = touch.location(in: self)
        currentLine = .init(
            color: drawingColor,
            point: .init(point: point)
        )
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard
            let touch = touches.first,
            let currentLine = currentLine
        else { return }
        
        let previousPoint = currentLine.currentPoint
        
        if let coalescedTouches = event?.coalescedTouches(for: touch) {
            // last point is touches.first, so skipping
            for touch in coalescedTouches[0..<coalescedTouches.count-1] {
                let point = touch.preciseLocation(in: self)
                currentLine.appendPoint(.init(point: point))
            }
        }
        
        let point = LinePoint(point: touch.preciseLocation(in: self))
        currentLine.appendPoint(point)
        
        let lineWidth = currentLine.lineWidth
        let refreshRect = CGRect(p1: previousPoint, p2: point).insetBy(dx: -lineWidth, dy: -lineWidth)
        setNeedsDisplay(refreshRect)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let currentLine = currentLine else { return }
        
        previousLines.append(currentLine)
        self.currentLine = nil
        onUndoChanged?()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        guard let currentLine = currentLine else { return }
        
        previousLines.append(currentLine)
        self.currentLine = nil
        onUndoChanged?()
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
