//
//  Canvas.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/30/22.
//

import UIKit

final class Canvas {
    
    var rect = CGRect.zero
    var needsFullRedraw = true
    private(set) var activeLine: Line?
    private(set) var finishedLines = [Line]()
    
    var canUndo: Bool {
        !finishedLines.isEmpty
    }
    
    var lineWidth: Progress = .min
    
    private var velocities = [CGFloat]()
    
    private let minLineWidth = 1.0
    private let maxLinewidth = 10.0
    
    init() {
    }
    
    func draw(
        atLocation location: CGPoint,
        velocity: CGPoint,
        color: UIColor
    ) -> CGRect {
        let width = extractLineWidth(from: velocity)
        let point = LinePoint(position: location, width: width)
        
        velocities.append(width)
        
        if let activeLine = activeLine {
            return activeLine.appendPoint(point)
        } else {
            activeLine = .init(color: color, point: point)
            return .null
        }
    }
    
    func finishDrawing() -> CGRect {
        guard let activeLine = activeLine else { return .null }

        finishedLines.append(activeLine)
        self.activeLine = nil
        velocities.removeAll()
        needsFullRedraw = true
        
        return rect
    }
    
    func undo() {
        guard canUndo else { return }
        
        finishedLines.removeLast()
        needsFullRedraw = true
    }
    
    func clear() {
        finishedLines.removeAll()
        needsFullRedraw = true
    }
}

private extension Canvas {
    
    func extractLineWidth(from velocity: CGPoint) -> CGFloat {
        let length = velocity.length
        var size = (length / 166).clamped(minValue: 1, maxValue: 40)
        
        if let lastVelocity = velocities.last {
            size = size*0.2 + lastVelocity*0.8;
        }
        
        return size
    }
}
