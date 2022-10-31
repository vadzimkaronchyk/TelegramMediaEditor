//
//  CanvasTextView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/30/22.
//

import UIKit

final class CanvasTextView: UIView {
    
    private let textView = UITextView()
    private let textSizeSlider = ToolSizeSlider()
    
    private lazy var textSizeSliderCenterYConstraint = textSizeSlider
        .centerYAnchor
        .constraint(equalTo: centerYAnchor)
    
    var textColor = UIColor.white {
        didSet {
            textView.textColor = textColor
            textView.tintColor = textColor
        }
    }
    
    var textOrigin: CGPoint {
        .init(x: textContainerInset.left, y: textContainerInset.top)
    }
    
    var text: Text {
        .init(
            color: textView.textColor ?? .white,
            string: textView.text,
            fontSize: textSize,
            width: editingText?.width ?? textView.intrinsicContentSize.width
        )
    }
    
    var onTextChanged: VoidClosure?
    
    private var editingText: Text?
    private var textSizeProgress = Progress(0.75)
    private var textSize: Double {
        textSizeProgress.value(min: minTextSize, max: maxTextSize)
    }
    
    private let minTextSize = 6.0
    private let maxTextSize = 70.0
    private let textContainerInset = UIEdgeInsets(
        top: 8,
        left: 40,
        bottom: 0,
        right: 0
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupViews()
        addKeyboardObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setEditingText(_ text: Text?) {
        editingText = text
        textView.text = text?.string
        textSizeProgress = text.map { .init(value: $0.fontSize, min: minTextSize, max: maxTextSize) } ?? .init(0.75)
    }
    
    func makeActive() {
        textView.becomeFirstResponder()
    }
    
    func makeInactive() {
        textView.resignFirstResponder()
    }
}

private extension CanvasTextView {
    
    func setupLayout() {
        addSubview(textView)
        addSubview(textSizeSlider)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textSizeSlider.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            NSLayoutConstraint.pinViewToSuperviewConstraints(
                view: textView,
                superview: self
            ) +
            [textSizeSlider.centerXAnchor.constraint(equalTo: leadingAnchor),
             textSizeSliderCenterYConstraint,
             textSizeSlider.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 256/520),
             textSizeSlider.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 28/390)]
        )
    }
    
    func setupViews() {
        setupView()
        setupTextView()
        setupTextSizeSlider()
        setupState()
    }
    
    func setupView() {
        backgroundColor = .black.withAlphaComponent(0.5)
    }
    
    func setupTextView() {
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.textContainerInset = textContainerInset
    }
    
    func setupTextSizeSlider() {
        textSizeSlider.transform = .init(rotationAngle: -.pi/2)
        textSizeSlider.addTarget(self, action: #selector(textSizeSliderValueChanged), for: .valueChanged)
    }
    
    func setupState() {
        textSizeSlider.value = textSizeProgress
        refreshFont()
    }
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShowNotification),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHideNotification),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    func refreshFont() {
        textView.font = .systemFont(ofSize: textSize, weight: .bold)
    }
}

private extension CanvasTextView {
    
    @objc func handleKeyboardWillShowNotification(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = window
        else { return }
        
        let keyboardMinYInWindow = window.bounds.height - keyboardSize.height
        let viewMinYInWindow = convert(CGPoint.zero, to: window).y
        let textSizeSliderMidYInWindow = (keyboardMinYInWindow + viewMinYInWindow)/2
        
        guard textSizeSliderMidYInWindow > 0 else { return }
        
        let textSizeSliderMidY = window.convert(.init(x: 0, y: textSizeSliderMidYInWindow), to: self).y
        textSizeSliderCenterYConstraint.constant = textSizeSliderMidY - bounds.midY
        layoutIfNeeded()
    }
    
    @objc func handleKeyboardWillHideNotification(_ notification: Notification) {
        textSizeSliderCenterYConstraint.constant = 0
        layoutIfNeeded()
    }
    
    @objc func textSizeSliderValueChanged(_ sizeSlider: ToolSizeSlider) {
        textSizeProgress = sizeSlider.value
        refreshFont()
    }
}

extension CanvasTextView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        onTextChanged?()
    }
}
