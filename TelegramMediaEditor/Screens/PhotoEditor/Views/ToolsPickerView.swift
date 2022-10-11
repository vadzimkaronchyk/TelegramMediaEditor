//
//  ToolsPickerView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/11/22.
//

import UIKit

final class ToolsPickerView: UIView {
    
    private let toolsStackView = UIStackView()
    private let penView = PenView()
    private let brushView = BrushView()
    private let neonBrushView = NeonBrushView()
    private let pencilView = PencilView()
    private let lassoView = LassoView()
    private let eraserView = EraserView()
    private let bottomGradientLayer = CAGradientLayer()
    
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
        setupLayers()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = 16.0
        bottomGradientLayer.frame = .init(
            x: toolsStackView.frame.minX,
            y: toolsStackView.frame.maxY - height,
            width: toolsStackView.frame.width,
            height: height
        )
    }
}

// MARK: - Setup methods

private extension ToolsPickerView {
    
    func setupLayout() {
        addSubview(toolsStackView)
        
        toolsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toolsStackView.heightAnchor.constraint(equalToConstant: 88),
            toolsStackView.widthAnchor.constraint(equalToConstant: 240),
            toolsStackView.topAnchor.constraint(equalTo: topAnchor),
            toolsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func setupViews() {
        toolsStackView.axis = .horizontal
        toolsStackView.distribution = .fillEqually
        toolsStackView.spacing = 24
        toolsStackView.addArrangedSubview(penView)
        toolsStackView.addArrangedSubview(brushView)
        toolsStackView.addArrangedSubview(neonBrushView)
        toolsStackView.addArrangedSubview(pencilView)
        toolsStackView.addArrangedSubview(lassoView)
        toolsStackView.addArrangedSubview(eraserView)
    }
    
    func setupLayers() {
        layer.addSublayer(bottomGradientLayer)
        bottomGradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        bottomGradientLayer.locations = [0.0, 1.0]
    }
}
