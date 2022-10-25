//
//  TitleImageButton.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/27/22.
//

import UIKit

final class TitleImageButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let image = imageView?.image, let titleLabel = titleLabel else {
            return
        }
        
        imageEdgeInsets = .init(
            top: 0,
            left: bounds.width - image.size.width,
            bottom: 0,
            right: 0
        )
        
        titleEdgeInsets = .init(
            top: 0,
            left: titleLabel.frame.width - bounds.width,
            bottom: 0,
            right: image.size.width
        )
    }
}
