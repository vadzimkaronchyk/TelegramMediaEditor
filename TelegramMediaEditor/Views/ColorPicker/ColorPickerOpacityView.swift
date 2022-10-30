//
//  ColorPickerOpacityView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/13/22.
//

import UIKit

final class ColorPickerOpacityView: UIView, ColorPicker {
    
    private let sliderInputView = ColorSliderInputView(model: .alpha)
    
    var onColorSelected: Closure<HSBColor>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupLayout()
        setupViews()
    }
    
    func updateColor(_ color: HSBColor) {
        sliderInputView.updateColor(color)
    }
}

private extension ColorPickerOpacityView {
    
    func setupLayout() {
        addSubview(sliderInputView)
        sliderInputView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            NSLayoutConstraint.pinViewToSuperviewConstraints(
                view: sliderInputView,
                superview: self
            )
        )
    }
    
    func setupViews() {
        sliderInputView.title = "OPACITY"
        sliderInputView.onColorSelected = { [weak self] color in
            self?.onColorSelected?(color)
        }
    }
}
