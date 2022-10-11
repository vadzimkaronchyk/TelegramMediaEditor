//
//  EraserView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/10/22.
//

import UIKit

final class EraserView: UIView {
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
}

private extension EraserView {
    
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
        imageView.contentMode = .scaleAspectFill
        imageView.image = .init(named: "eraser")
    }
}
