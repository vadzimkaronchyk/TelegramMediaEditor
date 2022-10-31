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
    private var selectedTextView: CanvasCommitedTextView?
    
    private lazy var textTypingTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(handleTextTypingTapGesture)
    )
    
    var color = HSBColor.white {
        didSet {
            let uiColor = color.uiColor
            updateStrokeViewColor(uiColor)
            updateTextViewColor(color)
            updateSelectedTextViewColor(uiColor)
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
    var onTextEditingStarted: Closure<Bool>?
    var onTextEditingChanged: Closure<Text>?
    var onColorsCircleTapped: VoidClosure?
    var onColorSelected: Closure<HSBColor>?
    var onTextAlignmentChanged: Closure<NSTextAlignment>?
    
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
            resignSelectedTextView()
        case .text:
            hideStrokeView()
            showTextView()
            textTypingTapGestureRecognizer.isEnabled = true
        }
    }
    
    func updateTextAlignment(_ alignment: NSTextAlignment) {
        updateTextViewAlignment(alignment)
        updateSelectedTextViewAlignment(alignment)
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
        selectedTextView?.isHidden = false
        
        hideTextView()
        textView.makeInactive()
    }
    
    func commitEditedText() {
        if let selectedTextView = selectedTextView {
            selectedTextView.isHidden = false
            selectedTextView.updateText(textView.text)
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
        clipsToBounds = true
        strokeView.onDrawingLineFinished = { [weak self] line in
            guard let self = self else { return }
            self.addDrawedLine(line)
            self.onUndoChanged?()
        }
        textView.onTextChanged = { [weak self] in
            guard let self = self else { return }
            self.onTextEditingChanged?(self.textView.text)
        }
        textView.onColorsCircleTapped = { [weak self] in
            self?.onColorsCircleTapped?()
        }
        textView.onColorSelected = { [weak self] color in
            let uiColor = color.uiColor
            self?.updateStrokeViewColor(uiColor)
            self?.updateSelectedTextViewColor(uiColor)
            self?.onColorSelected?(color)
        }
        textView.onTextAlignmentChanged = { [weak self] alignment in
            self?.onTextAlignmentChanged?(alignment)
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
        selectTextView(textView)
        
        commitedViews.append(textView)
    }
    
    func resignSelectedTextView() {
        selectedTextView?.setSelected(false)
        selectedTextView = nil
    }
    
    func selectTextView(_ textView: CanvasCommitedTextView) {
        if let selectedTextView = selectedTextView {
            selectedTextView.setSelected(false)
        }
        selectedTextView = textView
        textView.setSelected(true)
        
        let text = textView.text
        let hsbColor = text.color.hsbColor
        updateTextViewAlignment(text.alignment)
        updateStrokeViewColor(text.color)
        updateTextViewColor(hsbColor)
        onColorSelected?(hsbColor)
        onTextAlignmentChanged?(text.alignment)
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
    
    func updateTextViewAlignment(_ alignment: NSTextAlignment) {
        textView.updateTextAlignment(alignment)
    }
    
    func updateSelectedTextViewAlignment(_ alignment: NSTextAlignment) {
        guard let selectedTextView = selectedTextView else {
            return
        }
        var text = selectedTextView.text
        text.alignment = alignment
        selectedTextView.updateText(text)
    }
    
    func updateStrokeViewColor(_ color: UIColor) {
        strokeView.drawingColor = color
    }
    
    func updateTextViewColor(_ color: HSBColor) {
        textView.updateTextColor(color)
    }
    
    func updateSelectedTextViewColor(_ color: UIColor) {
        guard let selectedTextView = selectedTextView else {
            return
        }
        
        var text = selectedTextView.text
        text.color = color
        selectedTextView.updateText(text)
    }
    
    func addSubview(textView: CanvasCommitedTextView) {
        insertSubview(textView, belowSubview: strokeView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        let textAdditionalInset = CGPoint(x: 5 - 16, y: -4) // TODO: remove hardcoded values
        let origin = self.textView.textOrigin + textAdditionalInset
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor, constant: origin.y),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: origin.x),
            textView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])
    }
    
    func addDrawedLine(_ line: Line) {
        let strokeView = CanvasCommitedStrokeView(line: line)
        strokeView.frame = bounds
        insertSubview(strokeView, belowSubview: self.strokeView)
        commitedViews.append(strokeView)
    }
    
    func showMenu(fromTextView textView: CanvasCommitedTextView) {
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
        menuController.showMenu(from: textView, rect: textView.bounds)
    }
}

private extension CanvasView {
    
    @objc func handleTextTypingTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        showTextView()
        resignSelectedTextView()
        onTextEditingStarted?(false)
    }
    
    @objc func handleTextViewTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let textView = gestureRecognizer.view as? CanvasCommitedTextView else {
            return
        }
        
        textView.becomeFirstResponder()
        selectTextView(textView)
        showMenu(fromTextView: textView)
    }
    
    @objc func textViewDeleteMenuItemTapped(_ menuItem: UIMenuItem) {
        guard let selectedTextView = selectedTextView else { return }
        
        commitedViews.removeAll { $0 === selectedTextView }
        selectedTextView.removeFromSuperview()
        resignSelectedTextView()
        onUndoChanged?()
    }
    
    @objc func textViewEditMenuItemTapped(_ menuItem: UIMenuItem) {
        guard let selectedTextView = selectedTextView else { return }
        
        selectedTextView.isHidden = true
        textView.setEditingText(selectedTextView.text)
        showTextView()
        
        onTextEditingStarted?(true)
    }
    
    @objc func textViewDuplicateMenuItemTapped(_ menuItem: UIMenuItem) {
        guard let selectedTextView = selectedTextView else { return }
        
        let text = selectedTextView.text
        addEditedText(text)
    }
    
    @objc func handleTextViewPanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        
        if gestureRecognizer.state == .began && view.isFirstResponder {
            UIMenuController.shared.hideMenu()
            view.resignFirstResponder()
        }
        
        let translation = gestureRecognizer.translation(in: view)
        view.transform = view.transform.translatedBy(x: translation.x, y: translation.y)
        gestureRecognizer.setTranslation(.zero, in: view)
    }
}
