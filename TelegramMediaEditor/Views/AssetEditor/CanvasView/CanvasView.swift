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
    
    private var focusedTextView: CanvasCommitedTextView?
    private var commitedViews = [UIView]()
    
    var drawingColor: UIColor {
        get { strokeView.drawingColor }
        set { strokeView.drawingColor = newValue }
    }
    
    var lineWidth: Progress {
        get { strokeView.lineWidth }
        set { strokeView.lineWidth = newValue }
    }
    
    var canUndo: Bool {
        !commitedViews.isEmpty
    }
    
    var onUndoChanged: VoidClosure?
    var onTextEditingStarted: VoidClosure?
    var onTextEditingChanged: Closure<Text>?
    
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
            strokeView.isHidden = false
            textView.isHidden = true
        case .text:
            strokeView.isHidden = true
            textView.isHidden = false
            textView.makeActive()
        }
    }
    
    func undo() {
        let view = commitedViews.removeLast()
        view.removeFromSuperview()
        onUndoChanged?()
    }
    
    func clearAll() {
        for commitedView in commitedViews {
            commitedView.removeFromSuperview()
        }
        commitedViews.removeAll()
        onUndoChanged?()
    }
    
    func cancelEditedText() {
        focusedTextView?.isHidden = false
        
        textView.isHidden = true
        textView.setEditingText(nil)
        textView.makeInactive()
    }
    
    func commitEditedText() {
        if let focusedTextView = focusedTextView {
            focusedTextView.isHidden = false
            focusedTextView.updateText(textView.text)
        } else {
            addEditedText(textView.text)
            onUndoChanged?()
        }
        
        textView.isHidden = true
        textView.setEditingText(nil)
        textView.makeInactive()
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
        strokeView.onDrawingLineFinished = { [weak self] line in
            guard let self = self else { return }
            self.addDrawedLine(line)
            self.onUndoChanged?()
        }
        textView.onTextChanged = { [weak self] in
            guard let self = self else { return }
            self.onTextEditingChanged?(self.textView.text)
        }
    }
    
    func addEditedText(_ text: Text) {
        let textView = CanvasCommitedTextView(text: text)
        textView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(handleTextViewTapGesture)
        ))
        textView.addGestureRecognizer(UIPanGestureRecognizer(
            target: self,
            action: #selector(handleTextViewPanGesture)
        ))
        
        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        let textViewAdditionalInset = CGPoint(x: 5, y: 0) // TODO: remove
        let origin = self.textView.textOrigin + textViewAdditionalInset
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor, constant: origin.y),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: origin.x)
        ])
        
        commitedViews.append(textView)
    }
    
    func addDrawedLine(_ line: Line) {
        let strokeView = CanvasCommitedStrokeView(line: line)
        strokeView.frame = bounds
        addSubview(strokeView)
        commitedViews.append(strokeView)
    }
}

private extension CanvasView {
    
    @objc func handleTextViewTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let view = gestureRecognizer.view as? CanvasCommitedTextView else {
            return
        }
        
        view.becomeFirstResponder()
        focusedTextView = view
        
        let menuController = UIMenuController.shared
        let deleteMenuItem = UIMenuItem(
            title: "Delete",
            action: #selector(textViewDeleteMenuItemTapped)
        )
        let editMenuItem = UIMenuItem(
            title: "Edit",
            action: #selector(textViewEditMenuItemTapped)
        )
        let duplicateMenuItem = UIMenuItem(
            title: "Duplicate",
            action: #selector(textViewDuplicateMenuItemTapped)
        )
        UIMenuController.shared.menuItems = [
            deleteMenuItem,
            editMenuItem,
            duplicateMenuItem
        ]
        menuController.showMenu(from: view, rect: view.bounds)
    }
    
    @objc func textViewDeleteMenuItemTapped(_ menuItem: UIMenuItem) {
        guard let focusedTextView = focusedTextView else { return }
        
        commitedViews.removeAll { $0 === focusedTextView }
        focusedTextView.removeFromSuperview()
        onUndoChanged?()
    }
    
    @objc func textViewEditMenuItemTapped(_ menuItem: UIMenuItem) {
        guard let focusedTextView = focusedTextView else { return }
        
        focusedTextView.isHidden = true
        textView.isHidden = false
        textView.setEditingText(focusedTextView.text)
        textView.makeActive()
        
        onTextEditingStarted?()
    }
    
    @objc func textViewDuplicateMenuItemTapped(_ menuItem: UIMenuItem) {
        guard let focusedTextView = focusedTextView else { return }
        
        let text = focusedTextView.text
        addEditedText(text)
    }
    
    @objc func handleTextViewPanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
    }
}
