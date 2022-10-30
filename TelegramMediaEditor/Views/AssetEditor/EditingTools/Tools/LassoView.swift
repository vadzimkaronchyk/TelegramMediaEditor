//
//  LassoView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/10/22.
//

import UIKit

final class LassoView: UIView, DrawingToolView {
    
    private let imageView = UIImageView()
    
    let tool = Tool.Drawing.lasso
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
}

private extension LassoView {
    
    func commonInit() {
        setupLayout()
        setupViews()
    }
    
    func setupLayout() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setupViews() {
        imageView.image = .init(named: "lasso")
        imageView.contentMode = .scaleAspectFill
    }
}
