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
    
    private var commitedViews = [UIView]()
    private var focusedTextView: CanvasCommitedTextView? {
        commitedViews.first { $0.isFirstResponder } as? CanvasCommitedTextView
    }
    private lazy var textTypingTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(handleTextTypingTapGesture)
    )
    
    var color: UIColor = .white {
        didSet {
            strokeView.drawingColor = color
            textView.textColor = color
        }
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
        addGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateActiveTool(_ tool: Tool) {
        activeTool = tool
        switch tool {
        case .drawing:
            hideTextView()
            showStrokeView()
            textTypingTapGestureRecognizer.isEnabled = false
        case .text:
            hideStrokeView()
            showTextView()
            textTypingTapGestureRecognizer.isEnabled = true
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
        
        hideTextView()
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
        
        hideTextView()
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
    
    func addGestureRecognizers() {
        addGestureRecognizer(textTypingTapGestureRecognizer)
    }
    
    func showStrokeView() {
        strokeView.isHidden = false
    }
    
    func hideStrokeView() {
        strokeView.isHidden = true
    }
    
    func showTextView() {
        textView.isHidden = false
        textView.makeActive()
    }
    
    func hideTextView() {
        textView.isHidden = true
        textView.setEditingText(nil)
    }
    
    func addEditedText(_ text: Text) {
        let textView = CanvasCommitedTextView(text: text)
        addGestureRecognizers(toTextView: textView)
        addSubview(textView: textView)
        
        commitedViews.append(textView)
    }
    
    func addGestureRecognizers(toTextView textView: CanvasCommitedTextView) {
        textView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(handleTextViewTapGesture)
        ))
        textView.addGestureRecognizer(UIPanGestureRecognizer(
            target: self,
            action: #selector(handleTextViewPanGesture)
        ))
    }
    
    func addSubview(textView: CanvasCommitedTextView) {
        insertSubview(textView, belowSubview: strokeView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        let textAdditionalInset = CGPoint(x: 5 - 16, y: -4) // TODO: remove hardcoded values
        let origin = self.textView.textOrigin + textAdditionalInset
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor, constant: origin.y),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: origin.x)
        ])
    }
    
    func addDrawedLine(_ line: Line) {
        let strokeView = CanvasCommitedStrokeView(line: line)
        strokeView.frame = bounds
        insertSubview(strokeView, belowSubview: self.strokeView)
        commitedViews.append(strokeView)
    }
}

private extension CanvasView {
    
    @objc func handleTextTypingTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        showTextView()
        onTextEditingStarted?()
    }
    
    @objc func handleTextViewTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let view = gestureRecognizer.view as? CanvasCommitedTextView else {
            return
        }
        
        view.becomeFirstResponder()
        
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
        textView.setEditingText(focusedTextView.text)
        showTextView()
        
        onTextEditingStarted?()
    }
    
    @objc func textViewDuplicateMenuItemTapped(_ menuItem: UIMenuItem) {
        guard let focusedTextView = focusedTextView else { return }
        
        let text = focusedTextView.text
        addEditedText(text)
    }
    
    @objc func handleTextViewPanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        
        let translation = gestureRecognizer.translation(in: view)
        view.transform = view.transform.translatedBy(x: translation.x, y: translation.y)
        gestureRecognizer.setTranslation(.zero, in: view)
    }
}
