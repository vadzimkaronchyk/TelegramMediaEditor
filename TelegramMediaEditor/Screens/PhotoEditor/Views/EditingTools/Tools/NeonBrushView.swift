//
//  NeonBrushView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/10/22.
//

import UIKit

final class NeonBrushView: UIView, DrawingToolView {
    
    private let toolImageView = UIImageView()
    private let topTipImageView = UIImageView()
    private let middleTipGradientLayer = CAGradientLayer()
    
    let tool = Tool.Drawing.neonBrush
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = 17.0
        middleTipGradientLayer.frame = .init(x: (toolImageView.frame.width - width) / 2, y: 36, width: width, height: 14)
    }
    
    func updateDrawingColor(_ color: UIColor) {
        topTipImageView.tintColor = color
        middleTipGradientLayer.backgroundColor = color.cgColor
    }
}

private extension NeonBrushView {
    
    func commonInit() {
        setupLayout()
        setupViews()
        setupLayers()
        updateDrawingColor(.init(red: 0.196, green: 0.996, blue: 0.729, alpha: 1))
    }
    
    func setupLayout() {
        addSubview(toolImageView)
        addSubview(topTipImageView)
        
        toolImageView.translatesAutoresizingMaskIntoConstraints = false
        topTipImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.pinViewToSuperviewConstraints(view: toolImageView, superview: self) +
            NSLayoutConstraint.pinViewToSuperviewConstraints(view: topTipImageView, superview: self)
        )
    }
    
    func setupViews() {
        setupToolImageView()
        setupTopTipImageView()
        setupLayers()
    }
    
    func setupToolImageView() {
        toolImageView.image = .init(named: "neon")
        toolImageView.contentMode = .scaleAspectFill
    }
    
    func setupTopTipImageView() {
        topTipImageView.image = .init(named: "neon-tip")
        topTipImageView.contentMode = .scaleAspectFill
    }
    
    func setupLayers() {
        layer.addSublayer(middleTipGradientLayer)
        middleTipGradientLayer.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        ]
        middleTipGradientLayer.locations = [0, 0.15, 0.85, 1]
        middleTipGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        middleTipGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
    }
}
