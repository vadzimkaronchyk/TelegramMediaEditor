//
//  AddColorCell.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 17.10.22.
//

import UIKit

final class AddColorCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    
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
        
        imageView.layer.cornerRadius = imageView.bounds.width/2
    }
}

private extension AddColorCell {
    
    func setupLayout() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            NSLayoutConstraint.pinViewToSuperviewConstraints(
                view: imageView,
                superview: self
            )
        )
    }
    
    func setupViews() {
        imageView.image = .init(named: "add")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        imageView.backgroundColor = .init(red: 0.463, green: 0.463, blue: 0.502, alpha: 0.24)
    }
}
