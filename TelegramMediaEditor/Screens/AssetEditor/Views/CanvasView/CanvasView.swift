//
//  CanvasView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/24/22.
//

import UIKit

final class CanvasView: UIView {
    
    private let strokeView = CanvasStrokeView()
    private let textView = CanvasTextView()
    
    var drawingColor: UIColor {
        get { strokeView.drawingColor }
        set { strokeView.drawingColor = newValue }
    }
    
    var lineWidth: Progress {
        get { strokeView.lineWidth }
        set { strokeView.lineWidth = newValue }
    }
    
    var canUndo: Bool {
        strokeView.canUndo
    }
    
    var onUndoChanged: VoidClosure?
    
    private var activeTool = Tool.drawing(.pen)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateActiveTool(_ tool: Tool) {
        activeTool = tool
        switch tool {
        case .drawing:
            strokeView.isUserInteractionEnabled = true
            textView.isUserInteractionEnabled = false
            textView.isHidden = true
        case .text:
            strokeView.isUserInteractionEnabled = false
            textView.isUserInteractionEnabled = true
            textView.isHidden = false
            textView.makeActive()
        }
    }
    
    func cancelTextEditing() {
    }
    
    func saveTextEditing() {
    }
}

private extension CanvasView {
    
    func setupLayout() {
        addSubview(strokeView)
        addSubview(textView)
        
        strokeView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.pinViewToSuperviewConstraints(
                view: strokeView,
                superview: self
            ) +
            NSLayoutConstraint.pinViewToSuperviewConstraints(
                view: textView,
                superview: self
            )
        )
    }

    func setupView() {
        backgroundColor = .clear
        strokeView.onUndoChanged = { [weak self] in
            self?.onUndoChanged?()
        }
    }
}

extension CanvasView {
    
    func undo() {
        strokeView.undo()
    }
    
    func clearAll() {
        strokeView.clearAll()
    }
}
