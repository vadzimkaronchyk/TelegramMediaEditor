//
//  ColorReticleView.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 23.10.22.
//

import UIKit

final class ColorReticleView: UIView {
    
    private let scopeImageView = UIImageView()
    private let strokeView = ColorReticleStrokeView()
    
    var color: HSBColor = .black {
        didSet { strokeView.color = color }
    }
    
    var image: UIImage? {
        get { scopeImageView.image }
        set { scopeImageView.image = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scopeImageView.layer.cornerRadius = scopeImageView.bounds.height/2
        scopeImageView.clipsToBounds = true
    }
}

private extension ColorReticleView {
    
    func setupLayout() {
        addSubview(scopeImageView)
        addSubview(strokeView)
        
        scopeImageView.translatesAutoresizingMaskIntoConstraints = false
        strokeView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.pinViewToSuperviewConstraints(view: scopeImageView, superview: self) +
            NSLayoutConstraint.pinViewToSuperviewConstraints(view: strokeView, superview: self)
        )
    }
    
    func setupViews() {
        backgroundColor = .clear
        scopeImageView.backgroundColor = .clear
        scopeImageView.layer.magnificationFilter = .nearest
    }
}
