//
//  MenuPopoverItemView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/12/22.
//

import UIKit

final class MenuPopoverItemView: UIView {
    
    private let titleLabel = UILabel()
    private let trailingImageView = UIImageView()
    private let separatorView = UIView()
    
    private var highlightedColor: UIColor {
        .gray
    }
    
    private var normalColor: UIColor {
        .clear
    }
    
    var onSelected: VoidClosure?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 1.0
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear) {
            self.backgroundColor = self.highlightedColor
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear) {
            self.backgroundColor = self.normalColor
        }
        onSelected?()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 0.5
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear) {
            self.backgroundColor = self.normalColor
        }
    }
    
    func setup(item: MenuPopoverItem, displaySeparator: Bool) {
        titleLabel.text = item.title
        trailingImageView.image = .init(named: item.imageName)
        separatorView.isHidden = !displaySeparator
    }
}

private extension MenuPopoverItemView {
    
    func commonInit() {
        setupLayout()
        setupViews()
    }
    
    func setupLayout() {
        addSubview(titleLabel)
        addSubview(trailingImageView)
        addSubview(separatorView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        trailingImageView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingImageView.leadingAnchor, constant: 16),
            trailingImageView.heightAnchor.constraint(equalToConstant: 24),
            trailingImageView.widthAnchor.constraint(equalTo: trailingImageView.heightAnchor),
            trailingImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            trailingImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            trailingImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 1.0/UIScreen.main.scale),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setupViews() {
        setupTitleLabel()
        setupTrailingImageView()
        setupSeparatorView()
    }
    
    func setupTitleLabel() {
        titleLabel.textColor = .white
    }
    
    func setupTrailingImageView() {
        trailingImageView.tintColor = .white
        trailingImageView.contentMode = .scaleAspectFill
    }
    
    func setupSeparatorView() {
        separatorView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
    }
}
