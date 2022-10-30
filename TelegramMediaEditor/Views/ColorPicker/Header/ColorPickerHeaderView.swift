//
//  ColorPickerHeaderView.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 18.10.22.
//

import UIKit

final class ColorPickerHeaderView: UIView {
    
    private let stackView = UIStackView()
    private let eyeDropperImageView = UIImageView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    var onEyeDropperTapped: VoidClosure?
    var onEyeDropperLongPressed: Closure<UIGestureRecognizer>?
    var onCloseTapped: VoidClosure?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateColor(_ color: HSBColor) {
        eyeDropperImageView.tintColor = color.uiColor
    }
}

private extension ColorPickerHeaderView {
    
    func setupLayout() {
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        eyeDropperImageView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            eyeDropperImageView.widthAnchor.constraint(equalTo: eyeDropperImageView.heightAnchor),
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor)
        ])
    }
    
    func setupViews() {
        setupStackView()
        setupEyeDropperImageView()
        setupTitleLabel()
        setupCloseButton()
        addGestureRecognizers()
    }
    
    func setupStackView() {
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.addArrangedSubviews([eyeDropperImageView, titleLabel, closeButton])
    }
    
    func setupEyeDropperImageView() {
        eyeDropperImageView.tintColor = .white
        eyeDropperImageView.image = .init(named: "eyedropper")
        eyeDropperImageView.contentMode = .center
        eyeDropperImageView.isUserInteractionEnabled = true
    }
    
    func setupTitleLabel() {
        titleLabel.text = "Colors"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
    }
    
    func setupCloseButton() {
        closeButton.tintColor = .white
        closeButton.setImage(.init(named: "close"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    func addGestureRecognizers() {
        eyeDropperImageView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(handleEyeDropperImageViewTapGesture)
        ))
        eyeDropperImageView.addGestureRecognizer(UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleEyeDropperImageViewLongPressGesture)
        ))
    }
}

private extension ColorPickerHeaderView {
    
    @objc func handleEyeDropperImageViewTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        onEyeDropperTapped?()
    }
    
    @objc func handleEyeDropperImageViewLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        onEyeDropperLongPressed?(gestureRecognizer)
    }
    
    @objc func closeButtonTapped(_ button: UIButton) {
        onCloseTapped?()
    }
}
