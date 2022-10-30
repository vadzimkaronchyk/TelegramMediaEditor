//
//  ColorCodeView.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 18.10.22.
//

import UIKit

final class ColorCodeView: UIView, ColorPicker {
    
    private let colorCodeTypeLabel = UILabel()
    private let colorCodeTextField = ColorCodeTextField(model: .hex)
    
    var onColorSelected: Closure<HSBColor>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateColor(_ color: HSBColor) {
        colorCodeTextField.color = color
    }
}

private extension ColorCodeView {
    
    func setupLayout() {
        addSubview(colorCodeTypeLabel)
        addSubview(colorCodeTextField)
        
        colorCodeTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        colorCodeTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorCodeTypeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            colorCodeTypeLabel.trailingAnchor.constraint(equalTo: colorCodeTextField.leadingAnchor, constant: -12),
            colorCodeTextField.heightAnchor.constraint(equalToConstant: 36),
            colorCodeTextField.widthAnchor.constraint(equalToConstant: 77),
            colorCodeTextField.topAnchor.constraint(equalTo: topAnchor),
            colorCodeTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            colorCodeTextField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setupViews() {
        setupColorCodeTypeLabel()
        setupColorCodeTextField()
    }
    
    func setupColorCodeTypeLabel() {
        colorCodeTypeLabel.font = .systemFont(ofSize: 17, weight: .regular)
        colorCodeTypeLabel.text = "Display P3 Hex Color #"
        colorCodeTypeLabel.textColor = .white
    }
    
    func setupColorCodeTextField() {
        colorCodeTextField.onColorChanged = { [weak self] color in
            self?.onColorSelected?(color)
        }
    }
}
