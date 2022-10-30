//
//  ColorPickerRGBView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/13/22.
//

import UIKit

final class ColorPickerRGBView: UIView, ColorPicker {
    
    private let stackView = UIStackView()
    private let redColorSliderView = ColorSliderInputView(model: .red)
    private let greenColorSliderView = ColorSliderInputView(model: .green)
    private let blueColorSliderView = ColorSliderInputView(model: .blue)
    private let colorCodeView = ColorCodeView()
    
    private var colorPickers: [ColorPicker] {
        [redColorSliderView,
         greenColorSliderView,
         blueColorSliderView,
         colorCodeView]
    }
    
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
        updateColor(color, sender: nil)
    }
}

private extension ColorPickerRGBView {
    
    func setupLayout() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 12/10),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func setupViews() {
        setupStackView()
        setupColorSliderViews()
        setupColorPickers()
    }
    
    func setupStackView() {
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.addArrangedSubviews([
            redColorSliderView,
            greenColorSliderView,
            blueColorSliderView,
            colorCodeView
        ])
    }
    
    func setupColorSliderViews() {
        redColorSliderView.title = "RED"
        greenColorSliderView.title = "GREEN"
        blueColorSliderView.title = "BLUE"
    }
    
    func setupColorPickers() {
        for view in colorPickers {
            view.onColorSelected = { [weak self, weak view] color in
                guard let view = view else { return }
                self?.handleColorChange(color, sender: view)
            }
        }
    }
    
    func handleColorChange(_ color: HSBColor, sender: UIView? = nil) {
        updateColor(color, sender: sender)
        onColorSelected?(color)
    }
    
    func updateColor(_ color: HSBColor, sender: UIView?) {
        for view in colorPickers where view != sender {
            view.updateColor(color)
        }
    }
}
