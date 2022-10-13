//
//  ColorPickerColorsView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/13/22.
//

import UIKit

final class ColorPickerColorsView: UIView {
    
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
}

private extension ColorPickerColorsView {
    
    func setupLayout() {
    }
    
    func setupViews() {
        backgroundColor = .cyan
    }
}
