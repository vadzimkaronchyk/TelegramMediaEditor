//
//  ColorSliderInputView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/14/22.
//

import UIKit

final class ColorSliderInputView: UIView, ColorPicker {
    
    private let titleLabel = UILabel()
    private let sliderView: ColorSliderView
    private let valueTextField: ColorSliderTextField
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var onColorSelected: Closure<HSBColor>?
    
    init(model: ColorSliderInputModel) {
        sliderView = .init(model: model.sliderModel)
        valueTextField = .init(model: model.textFieldModel)
        super.init(frame: .zero)
        
        setupLayout()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateColor(_ color: HSBColor) {
        sliderView.color = color
        updateValueTextField()
    }
}

private extension ColorSliderInputView {
    
    func setupLayout() {
        addSubview(titleLabel)
        addSubview(sliderView)
        addSubview(valueTextField)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        valueTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 18),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: sliderView.topAnchor, constant: -4),
            sliderView.heightAnchor.constraint(equalToConstant: 36),
            sliderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sliderView.trailingAnchor.constraint(equalTo: valueTextField.leadingAnchor, constant: -12),
            sliderView.bottomAnchor.constraint(equalTo: bottomAnchor),
            valueTextField.widthAnchor.constraint(equalToConstant: 77),
            valueTextField.topAnchor.constraint(equalTo: sliderView.topAnchor),
            valueTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueTextField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setupViews() {
        setupTitleLabel()
        setupSliderView()
        setupValueTextField()
    }
    
    func setupTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .init(red: 0.922, green: 0.922, blue: 0.961, alpha: 0.6)
    }
    
    func setupSliderView() {
        sliderView.onColorChanged = { [weak self] color in
            self?.handleColorChange(color)
        }
    }
    
    func setupValueTextField() {
        valueTextField.onProgressChanged = { [weak self] progress in
            self?.handleProgressChange(progress)
        }
    }
}

private extension ColorSliderInputView {
    
    func handleColorChange(_ color: HSBColor) {
        updateValueTextField()
        onColorSelected?(color)
    }
    
    func handleProgressChange(_ progress: Progress) {
        sliderView.progress = progress
        onColorSelected?(sliderView.color)
    }
    
    func updateValueTextField() {
        let progress = sliderView.progress
        valueTextField.progress = progress
    }
}
