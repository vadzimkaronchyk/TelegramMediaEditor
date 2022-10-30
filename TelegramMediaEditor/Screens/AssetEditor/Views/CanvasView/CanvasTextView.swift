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
    
    var textContainerInset: UIEdgeInsets?
    
    private let minTextSize = 6.0
    private let maxTextSize = 70.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupViews()
        addKeyboardObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let textSize = textView.font?.pointSize ?? 0
        textView.textContainerInset = textContainerInset ?? .init(
            top: textSizeSlider.frame.midY - textSize/2,
            left: textSizeSlider.frame.maxX + 8,
            bottom: 0,
            right: 0
        )
    }
    
    func makeActive() {
        textView.becomeFirstResponder()
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
        backgroundColor = .clear
    }
    
    func setupTextView() {
        textView.textColor = .white
        textView.tintColor = .white
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
    }
    
    func setupTextSizeSlider() {
        textSizeSlider.transform = .init(rotationAngle: -.pi/2)
        textSizeSlider.addTarget(self, action: #selector(textSizeSliderValueChanged), for: .valueChanged)
    }
    
    func setupState() {
        let progress = Progress(0.75)
        textSizeSlider.value = progress
        updateTextSize(progress: progress)
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
    
    func updateTextSize(progress: Progress) {
        let size = progress.value(min: minTextSize, max: maxTextSize)
        textView.font = .systemFont(ofSize: size, weight: .bold)
    }
    
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
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
    }
    
    @objc func textSizeSliderValueChanged(_ sizeSlider: ToolSizeSlider) {
        let progress = sizeSlider.value
        updateTextSize(progress: progress)
    }
}
