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
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        var lines = previousLines
        if let currentLine = currentLine {
            lines.append(currentLine)
        }
        lines.forEach { $0.drawInContext(context) }
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
