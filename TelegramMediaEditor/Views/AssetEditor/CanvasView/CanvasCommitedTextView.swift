//
//  CanvasCommitedTextView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/30/22.
//

import UIKit

final class CanvasCommitedTextView: UIView {
    
    private let textLabel = UILabel()
    
    override var canBecomeFirstResponder: Bool {
        true
    }
    
    var text: Text
    
    init(text: Text) {
        self.text = text
        super.init(frame: .zero)
        
        setupLayout()
        setupViews()
        updateText(text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateText(_ text: Text) {
        textLabel.text = text.string
        textLabel.font = .systemFont(ofSize: text.fontSize, weight: .bold)
    }
}

private extension CanvasCommitedTextView {
    
    func setupLayout() {
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            NSLayoutConstraint.pinViewToSuperviewConstraints(
                view: textLabel,
                superview: self
            )
        )
    }
    
    func setupViews() {
        setupView()
        setupTextLabel()
    }
    
    func setupView() {
        backgroundColor = .clear
    }
    
    func setupTextLabel() {
        textLabel.textColor = .white
        textLabel.numberOfLines = 0
    }
}
