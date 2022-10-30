//
//  ColorPickerColorsView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/13/22.
//

import UIKit

final class ColorPickerColorsView: UIView, ColorPicker {
    
    private let previewView = ColorPreviewView()
    private let colorsView = ColorsView()
    
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
        previewView.color = color
        colorsView.selectedColor = color
    }
}

private extension ColorPickerColorsView {
    
    func setupLayout() {
        addSubview(previewView)
        addSubview(colorsView)
        
        previewView.translatesAutoresizingMaskIntoConstraints = false
        colorsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            previewView.heightAnchor.constraint(equalToConstant: 82),
            previewView.widthAnchor.constraint(equalTo: previewView.heightAnchor),
            previewView.topAnchor.constraint(equalTo: topAnchor),
            previewView.leadingAnchor.constraint(equalTo: leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: colorsView.leadingAnchor, constant: -36),
            previewView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            colorsView.topAnchor.constraint(equalTo: topAnchor),
            colorsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            colorsView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setupViews() {
        backgroundColor = .clear
    }
}
