//
//  Canvas.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/30/22.
//

import UIKit

enum CanvasDrawing {
    case stroke(Line)
    case text(Text)
}

final class Canvas {
    
    private(set) var finishedDrawings = [CanvasDrawing]()
    
    var canUndo: Bool {
        !finishedDrawings.isEmpty
    }
    
    init() {
    }
    
    func addLine(_ line: Line) {
        finishedDrawings.append(.stroke(line))
    }
    
    func addText(_ text: Text) {
        finishedDrawings.append(.text(text))
    }
    
    func undo() {
        guard canUndo else { return }
        finishedDrawings.removeLast()
    }
    
    func clear() {
        finishedDrawings.removeAll()
    }
}
